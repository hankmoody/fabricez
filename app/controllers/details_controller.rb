class DetailController < ActionController
  protect_from_forgery

  def detail_params
    params.require(:detail).permit(:first_name, :last_name, :company_name, :address1, :address2,
                                   :address3, :country, :state, :city, :zip, :phone, :logo)
  end

end
