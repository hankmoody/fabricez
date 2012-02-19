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
    @fabric = Fabric.new(params[:fabric].merge(:code => "Unprocessed"))
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
    fabric_params = params[:fabric]
    fabric_params[:reed_pick_attributes][:_destroy] = '1' if fabric_params[:reed_pick_attributes][:full_reed_pick] == "" 
    fabric_params[:yarn_count_attributes][:_destroy] = '1' if fabric_params[:yarn_count_attributes][:full_count] == ""
    
    puts fabric_params.inspect
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
  end

  def edit
    @fabric = Fabric.find(params[:id])
    
    # Build nested attributes
    @fabric.build_yarn_count if @fabric.yarn_count.nil?
    @fabric.build_reed_pick if @fabric.reed_pick.nil?
    
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
    
end
