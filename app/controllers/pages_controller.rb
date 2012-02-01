class PagesController < ApplicationController
  def home
    @title = "Cns Gallery"
    #@fabrics = Fabric.filter_fabrics(params).page(params[:page]).per(9)
    @fabrics = Fabric.filter_fabrics(params);
    # @fabrics = Fabric.all
    @fabrics = Kaminari.paginate_array(@fabrics).page(params[:page]).per(9)
  end
  
  def explore
    @title = "Fabric Explorer"
    @fabrics = Fabric.filter_fabrics(params);
    @fabrics = Kaminari.paginate_array(@fabrics).page(params[:page]).per(9)    
  end

  def contact
  end

  
  def userprofile
  end

end
