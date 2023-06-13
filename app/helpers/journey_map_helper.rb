module JourneyMapHelper
  def build_map_data(journey, current_station = nil)
    # Stations already added to the journey
    visited_stations = journey.steps
                              .includes(line: :station_end)
                              .select { |step| step.kind == "line" }
                              .map { |step| [step.line.station_start, step.line.station_end] }
                              .flatten
                              .unshift(journey.station_start) # journey starting point at the beginning of array

    visited_lines = journey.steps
                           .includes(:line)
                           .select { |step| step.kind == "line" }
                           .map(&:line)

    current_station = visited_stations.last if current_station.nil?

    # Find lines originating from the latest visited station,
    # and remove the ones that go to an already visited station
    possible_lines = Line.includes(:station_end)
                         .where(station_start: current_station)
                         .reject { |line| visited_stations.include?(line.station_end) }

    # Group lines by db_trip_id, to allow drawing of real train trips
    trips = possible_lines.group_by(&:db_trip_id) # hash of arrays

    # Build geojson for Mapbox
    {
      trip_lines: geojson_trips(current_station, trips),
      reachable_stations: geojson_reachable(possible_lines),
      selected_stations: geojson_selected(visited_stations),
      existing_lines: geojson_lines(visited_lines),
      steps_lines: journey.steps.where(kind: "line"),
      steps_stays: journey.steps.where(kind: "stay"),
      current_station: geojson_station(current_station)
    }
  end
end
