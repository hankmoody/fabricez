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
    
  end
  
  def edit
    @user = current_user
  end
  
    
  # Devise provides everything except show action
  # Creating a show action for User Model.
  def show
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

end
