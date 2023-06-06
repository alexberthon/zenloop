class LinesController < ApplicationController
  def index
  end

  def show
    @line = Line.find(params[:id])
    @line_start = Station.find(@line.station_start_id)
    @line_end = Station.find(@line.station_end_id)
    @stations = Station.where(["id = #{@line_start.id} or id = #{@line_end.id}"])

    @markers = @stations.map do |station|
      {
        lat: station.latitude,
        lng: station.longitude
      }
    end
  end
end
