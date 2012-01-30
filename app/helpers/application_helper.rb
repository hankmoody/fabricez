module ApplicationHelper
    
  def rupees (price)
    number_to_currency price, :unit => "Rs. ", :separator => ".", :precision => 0
  end
   
  def format_qty (qty)
    number_with_precision qty, :precision => 0
  end 
   
end
