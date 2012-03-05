class UsersController < ApplicationController
  
  # A user has to be signed in to view contents of this controller
  before_filter :authenticate_user!
  
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
    ret = @user.update_attributes(params[:user])
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
  
  def edit
    @user = current_user
  end
  
    
  # Devise provides everything except show action
  # Creating a show action for User Model.
  def show
    @user = User.find(params[:id])
  end

end
