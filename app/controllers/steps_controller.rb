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
        response = build_map_data(@journey)

        format.json { render json: response }
      else
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @step = Step.find(params[:id])
    @step.destroy
    @journey = @step.journey
    redirect_to journey_path(@journey)
  end

  private

  def step_params
    params.permit(:line_id)
  end
end
