class LinesController < ApplicationController
  include GeojsonHelper

  def show
    @line = Line.find(params[:id])
    @line_start = Station.find(@line.station_start_id)
    @line_end = Station.find(@line.station_end_id)
    @stations = Station.where(["id = #{@line_start.id} or id = #{@line_end.id}"])
  end

  def search
    if search_params[:from].blank?
      respond_to do |format|
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end

    station = Station.find(search_params[:from])
    lines = Line.includes(:station_end)
                .where(station_start: station)
    trips = lines.group_by(&:db_trip_id)
    response = {
      reachable_stations: geojson_reachable(lines),
      current_station: geojson_station(station),
      trip_lines: geojson_trips(station, trips)
    }
    respond_to do |format|
      format.json { render json: response }
    end
  end

  private

  def search_params
    params.permit(:from)
  end
end
