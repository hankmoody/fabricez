module ApplicationHelper
    
  def rupees (price)
    number_to_currency price, :unit => "Rs. ", :separator => ".", :precision => 0
  end
   
  def format_qty (qty)
    number_with_precision qty, :precision => 0
  end 
   
  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
    @resource.build_detail
    return @resource
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end  
       
   
   
end
