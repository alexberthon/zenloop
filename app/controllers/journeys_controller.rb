class JourneysController < ApplicationController
  include JourneyMapHelper
  include GeojsonHelper

  before_action :authenticate_user!
  before_action :set_journey, only: %i[show edit update destroy]

  def index
    @journeys = Journey.where(user: current_user)
  end

  def show
  end

  def create
    @station_start = Station.find(journey_params[:station_start_id])
    @journey = Journey.new(
      station_start: @station_start,
      station_end: @station_start,
      user: current_user,
      duration: 0,
      name: "New trip from #{@station_start.city.name}!"
    )
    if @journey.save!
      redirect_to edit_journey_path(@journey)
    else
      render "pages/home", status: :unprocessable_entity
    end
  end

  def edit
    @journey = Journey.find(params[:id])
    data = build_map_data(@journey)

    @selected_stations = data[:selected_stations]
    @reachable_stations = data[:reachable_stations]
    @trip_lines = data[:trip_lines]
    @existing_lines = data[:existing_lines]
    @stations = @journey.steps
                        .includes(line: :station_end)
                        .select { |step| step.kind == "line" }
                        .map { |step| step.line.station_end }
                        .unshift(@journey.station_start)
    @steps_lines = data[:steps_lines]
    @steps_stays = data[:steps_stays]
    @current_station = data[:current_station]

    @current_step_id = @journey.steps.present? ? @journey.steps.last.id : ""
  end

  def update
    @journey = Journey.find(params[:id])

    if @journey.update(journey_params)
      redirect_to params[:change].present? ? edit_journey_path : journey_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @journey.destroy
    redirect_to journeys_path
  end

  def like
    @journey = Journey.find(params[:id])
    @journey_like = @journey.likes.find_by(user_id: current_user)
    if @journey_like
      @journey_like.destroy
    else
      new_like = Like.create(user_id: current_user.id, journey_id: @journey.id)
      @journey.likes << new_like
    end
    redirect_to root_path
  end

  private

  def journey_params
    params.require(:journey).permit(:station_start_id, :name, :photo)
  end

  def set_journey
    @journey = Journey.includes(steps: :line).find(params[:id])
  end
end
