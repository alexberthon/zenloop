class StationsController < ApplicationController
  def index
    @lines = Line.all
    @stations = Station.all

    @markers = @stations.geocoded.map do |station|
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
