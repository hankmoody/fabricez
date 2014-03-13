class ReedPickController < ActionController
  protect_from_forgery

  def reed_pick_params
    params.require(:reed_pick).permit(:full_reed_pick, :reed, :pick)
  end

end
