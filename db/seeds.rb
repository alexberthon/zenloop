require "json"
require "open-uri"
require "pry-byebug"

DB_BASE_URL = "https://zenloop-db-rest.herokuapp.com"
# DB_BASE_URL = "http://localhost:3001"
DELAY = 0
DATE = URI.encode_www_form_component(Time.now.next_day.beginning_of_day.strftime("%Y-%m-%dT%H:%M:%S%:z"))
CITIES = [
  {
    name: "Paris",
    population: 2_145_906
  },
  {
    name: "Marseille",
    population: 870_321
  },
  {
    name: "Lyon",
    population: 522_228
  },
  {
    name: "Toulouse",
    population: 498_003
  },
  {
    name: "Nice",
    population: 343_477
  }
]

User.destroy_all
Station.destroy_all
City.destroy_all

puts "Seeding database..."

User.create(name: 'Alexis', email: 'alexis@gmail.com', password: 'azerty')
User.create(name: 'Antoine', email: 'antoine@gmail.com', password: 'azerty')
User.create(name: 'Alexandre', email: 'alexandre@gmail.com', password: 'azerty')
User.create(name: 'Lenny', email: 'lenny@gmail.com', password: 'azerty')

def fetch_stations(name, results)
  stations_url = "#{DB_BASE_URL}/locations?query=#{name}&poi=false&fuzzy=false&addresses=false&results=#{results}"
  stations_data_serialized = URI.open(stations_url).read
  stations_data = JSON.parse(stations_data_serialized).map(&:deep_symbolize_keys!)
  stations_data.reject do |station|
    station[:type] != "stop" ||
      station[:isMeta] ||
      (!station[:products][:nationalExpress] && station[:products][:national])
  end
end

def fetch_trips(station, results)
  departures_url = "#{DB_BASE_URL}/stops/#{station.db_stop_id}/departures?duration=1440&subway=false&regional=false&suburban=false&when=#{DATE}&results=#{results}"
  departures_data_serialized = URI.open(departures_url).read
  departures_data = JSON.parse(departures_data_serialized).deep_symbolize_keys[:departures]
  departures_data
    .uniq { |departure| "#{departure[:stop][:id]}_#{departure[:destination][:id]}" }
    .map { |departure| departure[:tripId] }
end

def fetch_trip(trip_id)
  trip_id = URI.encode_www_form_component(trip_id)
  trip_url = "#{DB_BASE_URL}/trips/#{trip_id}?remarks=false"
  trip_data_serialized = URI.open(trip_url).read
  JSON.parse(trip_data_serialized).deep_symbolize_keys[:trip]
end

# Create cities
CITIES.each do |city|
  City.create!(
    name: city[:name],
    country: "France",
    population: city[:population]
  )
end

# Create stations
City.all.each do |city|
  stations_data = fetch_stations(city.name, 10)
  stations_data.each do |station|
    Station.create(
      name: station[:name],
      latitude: station[:location][:latitude],
      longitude: station[:location][:longitude],
      db_stop_id: station[:id],
      city: city
    )
  end
end

Station.all.each do |station|
  trips = fetch_trips(station, 1000)
  trips.each_with_index do |trip_id, index|
    sleep(DELAY)
    trip = fetch_trip(trip_id)

    trip[:stopovers].each do |stopover|
      next if stopover[:stop][:id] == station.db_stop_id || stopover[:arrival].blank?

      if Station.exists?(db_stop_id: stopover[:stop][:id])
        next_station = Station.where(db_stop_id: stopover[:stop][:id]).first
      else
        next_station = Station.create!(
          name: stopover[:stop][:name],
          latitude: stopover[:stop][:location][:latitude],
          longitude: stopover[:stop][:location][:longitude],
          db_stop_id: stopover[:stop][:id],
          city: station.city
        )
      end

      line = Line.new(
        station_start: station,
        station_end: next_station,
        dt_start: Time.parse(trip[:departure]),
        dt_end: Time.parse(stopover[:arrival])
      )
      line.duration = ((line.dt_end - line.dt_start) / 60).to_i
      line.save
    end

    puts "[#{station.name}] #{index + 1}/#{trips.count} trips fetched"
  end
end

puts "--> Database seeded with #{User.count} users, #{City.count} cities, #{Station.count} stations and #{Line.count} lines"
