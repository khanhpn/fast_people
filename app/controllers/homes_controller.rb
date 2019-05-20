class HomesController < ApplicationController
  def index
    @proxy = Proxy.where(elite: true)
    @master_data = MasterDatum.all.size
    @raw_datum = RawDatum.new
  end

  def create
    user = RawDatum.new({raw_url: params["raw_url"], proxy_url: params["proxy_url"]})
    if user.save
      notice = "You updated successfuly"
    else
      notice = "Have some errors"
    end
    redirect_to root_path, notice: notice
  end
end
