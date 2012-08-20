class SessionsController < Devise::SessionsController
  
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in(resource_name, resource)
    #return render :json => {:success => true, :content => render_to_string(:layout => false, :partial => 'sessions/manager')}
    #return render :json => {:success => true}
    redirect_to portfolio_fabrics_path
    # respond_with resource do |format|
      # format.html { redirect_to after_sign_up_path_for(resource) }
    # end
  end

  def failure
    return render:json => {:success => false, :errors => ["Login failed."]}
  end
end