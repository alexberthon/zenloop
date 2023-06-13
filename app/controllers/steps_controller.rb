class StepsController < ApplicationController
  include JourneyMapHelper
  include GeojsonHelper

  def create
    journey = Journey.find(params[:journey_id])

    # Compute new step position
    if journey.steps.empty? || step_params[:step_id].blank?
      position = 0
    else
      position = Step.find(step_params[:step_id]).position + 1
    end

    step = Step.new(
      kind: step_params[:kind],
      journey: journey,
      position: position
    )

    if step_params[:kind] == "line"
      line = Line.find(step_params[:line_id])
      step.line = line
      step.duration = line.duration
    elsif step_params[:kind] == "stay"
      station = Station.find(step_params[:station_id])
      stay = Stay.new(
        city: station.city,
        duration: step_params[:duration]
      )
      step.stay = stay
      step.duration = step_params[:duration]
    end

    respond_to do |format|
      if step.save
        if step.kind == "line"
          current_station = step.line.station_end
          journey.update(
            station_end: current_station,
            duration: journey.duration + step.duration
          )
        elsif step.kind == "stay"
          current_station = station
          journey.update(
            duration: journey.duration + step.duration
          )
        end
        response = build_map_data(journey, current_station)
        response[:postcards] = journey.steps.map do |step|
          render_to_string(partial: "journeys/postcard", locals: { step: step }, layout: false, formats: :html)
        end.join
        response[:current_step_id] = step.id.to_s
        format.json { render json: response }
      else
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @step = Step.find(params[:id])

    respond_to do |format|
      if @step.destroy
        @journey = @step.journey
        if @step.kind == "line"
          if @journey.steps.empty? || @journey.steps.where(kind: "line").empty?
            station_end = @journey.station_start
            current_step_id = ""
          else
            station_end = @journey.steps.where(kind: "line").last.line.station_end
            current_step_id = @journey.steps.where(kind: "line").last.id.to_s
          end
          @journey.station_end = station_end
        end
        @journey.duration = @journey.duration - @step.duration
        @journey.save
        response = build_map_data(@journey)
        response[:current_step_id] = current_step_id
        format.json { render json: response }
      else
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  private

  def step_params
    params.permit(:kind, :line_id, :station_id, :step_id, :duration)
  end
end
