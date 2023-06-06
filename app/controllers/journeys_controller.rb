class JourneysController < ApplicationController
  before_action :authenticate_user!
  def index
    @stations = Station.all

    @search = params["search"]
    @querystation = Station.find_by(name: @search["name"])
    @stationchoisie = Station.where(["id = #{@querystation.id}"])

    @markers = @stationchoisie.geocoded.map do |station|
      {
        lat: station.latitude,
        lng: station.longitude
      }
    end
  end

  def show
    @station = Station.find(params[:id])
  end
end
