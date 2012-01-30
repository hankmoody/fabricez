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
    
end
