class JourneysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journey, only: %i[show update]

  def index
    @journeys = Journey.where(user_id: current_user.id)
  end

  def show
    @stations = Station.all

    @journey = Journey.find(params[:id])
    @visited_stations = @journey.steps
                                .includes(line: :station_end)
                                .map { |step| step.line.station_end }
                                .unshift(@journey.station_start)
    @station = @visited_stations.last

    @lines = Line.where(station_start: @station)
                 .includes(:station_end)
                 .reject { |line| @visited_stations.include?(line.station_end) }

    @reachable_stations = helpers.geojson_reachable(@lines)
    @selected_stations = helpers.geojson_selected(@visited_stations)

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

  def edit
    @journey = Journey.find(params[:id])
  end

  def update
    @journey = Journey.find(params[:id])

    if @journey.update(journey_params)
      redirect_to @journey
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def journey_params
    params.require(:journey).permit(:station_start_id, :name)
  end

  def set_journey
    @journey = Journey.find(params[:id])
  end
end
