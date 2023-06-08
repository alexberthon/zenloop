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

        response = { selected_stations: @selected_stations, reachable_stations: @reachable_stations, strokes: @strokes }

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
