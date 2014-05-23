class PagesController < ApplicationController
  def home
    @title = "Cns Gallery"
    @pagesize = params[:pagesize].nil? ? 9 : params[:pagesize].to_i 
    #@fabrics = Fabric.filter_fabrics(params).page(params[:page]).per(9)
    @fabrics = Fabric.filter_fabrics(params);
    # @fabrics = Fabric.all
    @fabrics = Kaminari.paginate_array(@fabrics).page(params[:page]).per(@pagesize)
  end
  
  def explore
    @title = "Fabric Explorer"
    @fabrics = Fabric.filter_fabrics(params);
    @fabrics = Kaminari.paginate_array(@fabrics).page(params[:page]).per(@pagesize)    
  end

  def contact
  end

  def userprofile
  end

end
