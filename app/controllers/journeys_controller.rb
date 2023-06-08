class JourneysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journey, only: %i[show]

  def index
    @journeys = Journey.all
  end

  def show
    @journey = Journey.find(params[:id])
    @station = @journey.station_start
    @stations = Station.all
    @lines = Line.where(station_start: @station).includes(:station_end)

    @reachable_stations = helpers.geojson_reachable(@lines)
    @selected_stations = helpers.geojson_selected([@station])

    trips = @lines.group_by(&:db_trip_id) # hash of arrays
    @strokes = helpers.geojson_trips(@station, trips)
  end

  def create
    @station_start = Station.find(journey_params[:station_start_id])
    @journey = Journey.new(
      station_start: @station_start,
      station_end: @station_start,
      user: current_user,
      name: "trip starting from " + @station_start.name
    )
    if @journey.save!
      redirect_to journey_path(@journey)
    else
      render "pages/home", status: :unprocessable_entity
    end
  end

  private

  def journey_params
    params.require(:journey).permit(:station_start_id)
  end

  def set_journey
    @journey = Journey.find(params[:id])
  end
end
