class StepsController < ApplicationController
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
      if @step.save!
        format.json { render json: {}, status: :ok }
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
