class RegistrationsController < Devise::RegistrationsController
  
  # def new
    # resource = build_resource({})
    # respond_with(resource) do |format|
      # format.json render :json => {:success => true}
    # end    
  # end


  # POST /resource
  def create
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource do |format|
          format.html { redirect_to after_sign_up_path_for(resource) }
          format.js { render :json => { :success => true, :active => true }.to_json }
        end
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource do |format| 
          format.html { redirect_to after_inactive_sign_up_path_for(resource) }
          format.js { render :json => { :success => true, :active => :false }.to_json }
        end
      end
    else
      clean_up_passwords resource
      respond_with resource do |format|
        format.js { render :json => { :success => false }.to_json }
      end
    end
  end  


end