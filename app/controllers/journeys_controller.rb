class JourneysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journey, only: %i[show update]

  def index
    @journeys = Journey.where(user_id: current_user.id)
  end

  def show
    @stations = Station.all

    @journey = Journey.find(params[:id])
    data = helpers.build_map_data(@journey)

    @selected_stations = data[:selected_stations]
    @reachable_stations = data[:reachable_stations]
    @trip_lines = data[:trip_lines]
    @existing_lines = data[:existing_lines]
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
