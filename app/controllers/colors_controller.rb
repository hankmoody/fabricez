class ColorController < ActionController
  protect_from_forgery

  def color_params
    params.require(:color).permit(:red, :green, :blue, :hexvalue, 
                                  :ciel_L, :ciel_a, :ciel_b)
  end

end
