module JourneyMapHelper
  def build_map_data(journey)
    visited_stations = journey.steps
                              .includes(line: :station_end)
                              .map { |step| step.line.station_end }
                              .unshift(journey.station_start) # add starting point at the beginning

    # Find lines originating from the latest visited station,
    # and remove the ones that go to an already visited station
    lines = Line.where(station_start: visited_stations.last)
                .includes(:station_end)
                .reject { |line| visited_stations.include?(line.station_end) }

    reachable_stations = geojson_reachable(lines)
    selected_stations = geojson_selected(visited_stations)

    # Group lines by db_trip_id, to allow drawing of real train trips
    trips = lines.group_by(&:db_trip_id) # hash of arrays
    strokes = geojson_trips(visited_stations.last, trips)

    { selected_stations:, reachable_stations:, strokes: }
  end
end
