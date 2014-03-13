class UsersController < ApplicationController
  
  # A user has to be signed in to view contents of this controller
  before_filter :authenticate_user!
  skip_before_filter :authenticate_user!, :only => [:check_if_signed_in]
  respond_to :html, :json
  
  def upload
    # Render in json format to pass information to upload widget
    # using AJAX.
    @user = current_user
    respond_to do |format|
      format.html { redirect_to(@user) }
      format.json { render :json => @user.to_jq_upload.to_json }  
    end
  end
  
  def update
    @user = User.find(params[:id])
    ret = @user.update_attributes(user_params)
    @u_errors = @user.errors if !ret
    respond_to do |format|
      if ret
        format.html { redirect_to(user_path(params[:id]), :notice => "Account details were successfully updated.") }
        format.json { render :json => {}, :status => :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @u_errors,
                      :status => :unprocessable_entity }
      end
    end
  end
  
  def update_collection
    @user = User.find(params[:id])
    bAlreadyExists = true
    if (!params['name_to_add'].nil?)
      c_name = params['name_to_add'].titleize
      bAlreadyExists = !@user.add_collection_name(c_name)
    elsif (!params['name_to_remove'].nil?)
      c_name = params['name_to_remove'].titleize
      @user.remove_collection_name(c_name)
    end
    
    if @user.save!
      respond_with do |format|
        format.html do
          if request.xhr?
            newhtml = render_to_string :partial => "collections/blocks", :layout => false, :locals => { :block_type => "CollectionNameList" }
            render :json => { "added" => bAlreadyExists ? 0 : 1,
                              "newhtml" => newhtml,
                              "c_name" => c_name }.to_json
          end
        end
      end
    else
      respond_with do |format|
        format.html do
          if request.xhr?
            render :json => @collection.errors, :status => :unprocessable_entity
          end
        end
      end
    end
    # render :json => { "added" => bAlreadyExists ? 0 : 1 }.to_json
  end
  
  def edit
    @user = current_user
  end
  
    
  # Devise provides everything except show action
  # Creating a show action for User Model.
  def show
    @user = User.find(params[:id])
  end

  def check_if_signed_in
    render :json => { "returnValue" => user_signed_in? }.to_json
  end

private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role, 
                                 :username, :detail_attributes)
  end

end
