require "json"
require "open-uri"

task :filter_stations do
  stations = File.readlines("db/data/stations.ndjson")
                 .map { |line| JSON.parse(line) }
                 .select { |station| station["products"]["nationalExpress"] || station["products"]["national"] }
                 .map(&:to_json)

  File.open("db/data/national_stations.ndjson", "w") do |f|
    f.puts(stations)
  end
end
