class StepsController < ApplicationController
  include JourneyMapHelper
  include GeojsonHelper

  def create
    journey = Journey.find(params[:journey_id])
    step = Step.new(
      kind: step_params[:kind],
      journey: journey
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
        response[:station_list_html] = render_to_string(partial: "journeys/station_list", locals: { journey: journey }, layout: false, formats: :html)
        response[:postcard] = render_to_string(partial: "journeys/postcard", locals: { step: step }, layout: false, formats: :html)
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
          last_line = @journey.steps.where(kind: "line").last.line
          @journey.station_end = @journey.steps.empty? ? @journey.station_start : last_line.station_end
        end
        @journey.duration = @journey.duration - @step.duration
        @journey.save
        response = build_map_data(@journey)
        response[:station_list_html] = render_to_string(partial: "journeys/station_list", locals: { journey: @journey }, layout: false, formats: :html)
        format.json { render json: response }
      else
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  private

  def step_params
    params.permit(:kind, :line_id, :station_id, :duration)
  end
end
