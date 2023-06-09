task export_lines: [:environment] do
  puts "Export in progress..."
  File.open("db/data/lines.ndjson", "w") do |f|
    f.puts(
      Line.includes(:station_start, :station_end)
          .map do |line|
            {
              station_start_db_stop_id: line.station_start.db_stop_id,
              station_end_db_stop_id: line.station_end.db_stop_id,
              dt_start: line.dt_start,
              dt_end: line.dt_end,
              duration: line.duration,
              db_trip_id: line.db_trip_id
            }
          end
          .map(&:to_json)
    )
  end
  puts "Done!"
end
