class LinesController < ApplicationController
  def index
  end

  def show
    @line = Line.find(params[:id])
    @linestart = Station.find(@line.station_start_id)
    @lineend = Station.find(@line.station_end_id)
    @stations = Station.where(["id = #{@linestart.id} or id = #{@lineend.id}"])

    @markers = @stations.geocoded.map do |station|
      {
        lat: station.latitude,
        lng: station.longitude
      }
    end
  end
end
