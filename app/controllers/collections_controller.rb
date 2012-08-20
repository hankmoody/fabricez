class CollectionsController < ApplicationController
  # A user has to be signed in to view contents of this controller
  before_filter :authenticate_user!
  #skip_before_filter :authenticate_user!, :only => [:show, :showall]  # skip authentication for showall action.
  skip_before_filter :authenticate_user!, :only => [:ezalbum] 


  def manage
    @user = current_user
    @collections = @user.collections
    render :action => "manage", :layout => "noheader"
  end
  
  def edit
    @user = current_user
    @collection = Collection.find(params[:id])
    @fabrics = Fabric.filter_fabrics(params, @user.fabrics)
    @fabrics = Kaminari.paginate_array(@fabrics).page(params[:page]).per(@pagesize)

    if request.xhr?
        newhtml = render_to_string :partial => "layouts/fabricalbum", 
                                   :layout => false,
                                   :locals => { :enable_select => true } 
    end
    
    respond_to do |format|
      format.html { render }
      format.json { render :json => { "newhtml" => newhtml }.to_json }
    end
    
  end
  
  def update
    @fabrics = Fabric.where(id: params['fabricid'])
    ret = false;
    if !@fabrics.empty?
      current_user.add_fabrics_to_collection(@fabrics, params[:id])
      ret = true;
    end
    render :json => { "returnValue" => true }.to_json
  end
    
  def ezalbum
    @user = current_user    
    @collection = Collection.find(params[:id])
    render :action => "ezalbum", :layout => "noheader"
  end
  
    
end
