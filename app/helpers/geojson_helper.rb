module GeojsonHelper
  def geojson_selected(stations)
    Jbuilder.new do |json|
      json.type "FeatureCollection"
      json.features stations do |station|
        json.type "Feature"
        json.id station.id
        json.properties do
          json.name station.name
        end
        json.geometry do
          json.type "Point"
          json.coordinates [station.longitude, station.latitude]
        end
      end
    end.attributes!.to_json
  end

  def geojson_reachable(lines)
    Jbuilder.new do |json|
      json.type "FeatureCollection"
      json.features lines do |line|
        json.type "Feature"
        json.id line.station_end.id
        json.properties do
          json.name line.station_end.name
          json.duration line.duration
          json.db_trip_id line.db_trip_id.gsub("|", "").to_i
        end
        json.geometry do
          json.type "Point"
          json.coordinates [line.station_end.longitude, line.station_end.latitude]
        end
      end
    end.attributes!.to_json
  end

  def geojson_trips(station_start, trips)
    Jbuilder.new do |json|
      json.type "FeatureCollection"
      json.features trips.values do |trip|
        json.type "Feature"
        json.id trip.first.db_trip_id.gsub("|", "").to_i
        json.geometry do
          json.type "LineString"
          json.coordinates(
            trip
              .map(&:station_end)
              .map { |station| [station.longitude, station.latitude] }
              .unshift([station_start.longitude, station_start.latitude])
          )
        end
      end
    end.attributes!.to_json
  end

  # def geojson_lines(station_start, reachable_stations)
  #   Jbuilder.new do |json|
  #     json.type "FeatureCollection"
  #     json.features reachable_stations do |reachable_station|
  #       json.type "Feature"
  #       json.geometry do
  #         json.type "LineString"
  #         json.coordinates [[station_start.longitude, station_start.latitude], [reachable_station.longitude, reachable_station.latitude]]
  #       end
  #     end
  #   end.attributes!.to_json
  # end
end
