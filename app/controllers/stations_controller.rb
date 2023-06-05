class StationsController < ApplicationController
  def index
    @stations = Station.all
    @markers = @stations.geocoded.map do |station|
      {
        lat: station.latitude,
        lng: station.longitude
      }
    end
  end
end
