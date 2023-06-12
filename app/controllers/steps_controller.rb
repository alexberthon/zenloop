class StepsController < ApplicationController
  include JourneyMapHelper
  include GeojsonHelper

  def create
    @journey = Journey.find(params[:journey_id])
    @line = Line.find(params[:line_id])
    @step = Step.new(
      kind: "line",
      line: @line,
      journey: @journey,
      duration: @line.duration
    )

    respond_to do |format|
      if @step.save
        @journey.update(
          station_end: @step.line.station_end,
          duration: @journey.duration + @step.duration
        )
        response = build_map_data(@journey, @step.line.station_end)
        response[:station_list_html] = render_to_string(partial: "journeys/station_list", locals: { journey: @journey }, layout: false, formats: :html)
        response[:postcard] = render_to_string(partial: "journeys/postcard", locals: { step: @step }, layout: false, formats: :html)
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
    params.permit(:line_id)
  end
end
