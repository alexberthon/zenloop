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

  def search
    @station = Station.find(search_params[:station_id])
    @lines = Line.where(station_start: @station).includes(:station_end)

    @reachable_stations = helpers.geojson_reachable(@lines)
    @selected_stations = helpers.geojson_selected([@station])

    trips = @lines.group_by(&:db_trip_id) # hash of arrays
    @strokes = helpers.geojson_trips(@station, trips)

    response = { reachable_stations: @reachable_stations, selected_stations: @selected_stations, strokes: @strokes }
    respond_to do |format|
      format.json { render json: response }
    end
  end

  private

  def search_params
    params.permit(:station_id)
  end
end
