class LinesController < ApplicationController
  include JourneyMapHelper
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
    journey = Journey.find(search_params[:journey_id])

    step = journey.steps.joins(:line).where("lines.station_end_id = ?", station.id).first

    response = build_map_data(journey, station)
    response[:current_step_id] = step.id.to_s
    respond_to do |format|
      format.json { render json: response }
    end
  end

  private

  def search_params
    params.permit(:from, :journey_id)
  end
end
