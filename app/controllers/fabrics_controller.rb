class FabricsController < ApplicationController
  # A user has to be signed in to view contents of this controller
  before_filter :authenticate_user!
  skip_before_filter :authenticate_user!, :only => [:show, :showall]  # skip authentication for showall action.
  
  # autocomplete :fabric, :tag_names
  
  def upload
    @user = current_user
    @fabric = Fabric.new
  end

  def index
    # This action will display all unprocessed designs for a user.
    # Mainly used for Upload Form.
    @user = current_user
    @fabrics = @user.get_for_display_type("unprocessed")
    render :json => @fabrics.collect { |f| f.to_jq_upload }.to_json
  end
  
  def create
    # Used for the upload form
    @user = current_user
    @fabric = Fabric.new(fabric_params.merge(:code => "Unprocessed"))
    if (@fabric.save)
      @fabric.extract_color_info
      @fabric.save
      @user.add_fabric_to_collection(@fabric, "default")
      render :json => [ @fabric.to_jq_upload ].to_json
    else
      render :json => [ @fabric.to_jq_upload.merge({ :error => "custom_failure" }) ].to_json
    end
  end
  
  def update
    @fabric = Fabric.find(params[:id])
    
    # Destroy empty nested attributes
    if fabric_params[:reed_pick_attributes]
      fabric_params[:reed_pick_attributes][:_destroy] = '1' if fabric_params[:reed_pick_attributes][:full_reed_pick] == "" 
    end
    if fabric_params[:yarn_count_attributes]
      fabric_params[:yarn_count_attributes][:_destroy] = '1' if fabric_params[:yarn_count_attributes][:full_count] == ""
    end
    
    #puts fabric_params.inspect
    @f_errors = nil
    ret = @fabric.update_attributes(fabric_params)
    @f_errors = @fabric.errors if !ret
    respond_to do |format|
      if ret
        redir_fabric_path = @fabric
        if (params[:commit] == "Update & Edit Next")
          redir_fabric = current_user.get_next_unproc
          redir_fabric_path = (redir_fabric.nil?) ? @fabric : edit_fabric_path(redir_fabric.id)
        end
        format.html { redirect_to(redir_fabric_path, :notice => "#{@fabric.code} was successfully updated.") }
        format.json { render :json => {}, :status => :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @f_errors,
                      :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @user = current_user
    # @fabric = Fabric.find(params[:id])
    # @fabric.destroy
    @user.remove_fabric(params[:id])
    respond_to do |format|
      if (params[:redirect_to])
        format.html { redirect_to(params[:redirect_to]) }
      end
      format.json { render :json => true, :status => :ok }
    end
  end
  
  def show
    @fabric = Fabric.find(params[:id])
    # Just pick the user from the first collection
    @user = @fabric.collections.first.user
  end

  def edit
    @fabric = Fabric.find(params[:id])
    
    # Build nested attributes
    @fabric.build_yarn_count if @fabric.yarn_count.nil?
    @fabric.build_reed_pick if @fabric.reed_pick.nil?
    
  end
  
  def crop
    @fabric = Fabric.find(params[:id])
    render :action => "crop", :layout => "noheader"
  end

  def update_crop
    @fabric = Fabric.find(params[:id])
    ret = @fabric.update_attributes(params["fabric"])
    if ret
      @fabric.cropping = true
      @fabric.attachment.reprocess!(:big, :thumb)
      render :text => "<script type='text/javascript'>  window.opener.location.reload(); window.close() </script>"
    else
      render :text => "Error encountered while updating this fabric."
    end
  end
  
  def publish
    @fabric = Fabric.find(params[:id])
    @fabric.published = true
    @fabric.save
    redirect_to(current_user)
  end
  
  def portfolio
    @user = current_user
    @pagesize = params[:pagesize].nil? ? 9 : params[:pagesize].to_i 
    if @user.role.category == "admin"
      @fabrics = Fabric.get_for_display_type("pending_review").page(params[:page]).per(@pagesize) 
    else
      # @fabrics = @user.get_for_display_type(params[:display]).page(params[:page]).per(9)
      # @fabrics = @user.get_for_display_type(params[:display]) 
      @fabrics = Kaminari.paginate_array(@user.get_for_display_type(params[:display])).page(params[:page]).per(@pagesize) 
    end
    @navlinks = { "All" => "all",
                  "Published" => "published",
                  "Pending Review" => "pending_review",
                  "Unprocessed" => "unprocessed" }
    # session[:return_to] ||= request.referer        
  end
  
  def bulk_edit
    @fabrics = Fabric.where(id: params['fabricid'])
  end
  
  def update_multiple
    @fabrics = Fabric.find(params[:fabric_ids])
    f_params = params["fabric"]
    
    # Non-fabric specific attributes
    sel_all_params = {}
    if params['yarn_count_chk'].eql?('1')
      sel_all_params[:yarn_count_attributes] = f_params[:yarn_count_attributes]
      sel_all_params[:yarn_count_attributes][:_destroy] = '1' if sel_params[:yarn_count_attributes][:full_count] == ""
    end      
    if params['reed_pick_chk'].eql?('1')
      sel_all_params[:reed_pick_attributes] = f_params[:reed_pick_attributes]
      sel_all_params[:reed_pick_attributes][:_destroy] = '1' if sel_params[:reed_pick_attributes][:full_reed_pick] == ""
    end
    
    sel_all_params[:width] = f_params[:width] if params['width_chk'].eql?('1')
    sel_all_params[:quantity] = f_params[:quantity] if params['quantity_chk'].eql?('1')
    sel_all_params[:price] = f_params[:price] if params['price_chk'].eql?('1')
    
    # Generic logic to handle tags
    tag_params = []
    Tag.get_default_tagtype_list.each do |t|
      if params["#{t}_chk"].eql?('1')
        sel_all_params["#{t}_tag_list".to_sym] = f_params["#{t}_tag_list".to_sym] if (params["#{t}_radio"] == 'Replace')
        tag_params << {tag_type: t, action: 'add', list: f_params["#{t}_tag_list".to_sym]} if (params["#{t}_radio"] == 'Add')
        tag_params << {tag_type: t, action: 'remove', list: f_params["#{t}_tag_list".to_sym]} if (params["#{t}_radio"] == 'Remove')
      end
    end
     
    # Update the fabrics    
    @fabrics.each do |f|
      sel_params = sel_all_params
      if params['yarn_count_chk'].eql?('1')
        sel_params[:yarn_count_attributes][:id] = f.yarn_count.id if !f.yarn_count.nil?
      end      
      if params['reed_pick_chk'].eql?('1')
        sel_params[:reed_pick_attributes][:id] = f.reed_pick.id if !f.reed_pick.nil?
      end
      f.update_tags(tag_params) unless tag_params.empty?
      f.update_attributes!(sel_params)
    end

    redirect_to(user_path, :notice => "Fabrics was successfully updated.")
  end
    
private

  def fabric_params
    params.require(:fabric).permit(:code, :width, :price, :quantity, :published, :processed,
                                   :attachment, :reed_pick, :yarn_count, :colors, :yarn_count_id,
                                   :yarn_count_attributes, :reed_pick_id, :reed_pick_attributes,
                                   :colors_attributes, :crop_x, :crop_y, :crop_w, :crop_h, :cropping)
  end

  def yarn_count_params
    params.require(:yarn_count).permit(:full_count, :warp_ply_count, :weft_ply_count, 
                                       :warp_yarn_thickness, :weft_yarn_thickness)
  end

end
