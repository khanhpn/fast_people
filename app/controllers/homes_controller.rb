class HomesController < ApplicationController
  def index
    @proxy = Proxy.where(elite: true)
    @master_data = MasterDatum.all.size
    @raw_datum = RawDatum.new
  end
end
