require "json"

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

puts "---------- DESTROY ----------"
puts ""

puts "Destroying users..."
User.destroy_all
puts "Users destroyed!"

puts "Destroying stations..."
Station.destroy_all
puts "Stations destroyed!"

puts "Destroying cities..."
City.destroy_all
puts "Cities destroyed!"

puts ""
puts "---------- CREATE ----------"
puts ""

# Create users
puts "Creating users..."
User.create(name: 'Alexis', email: 'alexis@gmail.com', password: 'azerty')
User.create(name: 'Antoine', email: 'antoine@gmail.com', password: 'azerty')
User.create(name: 'Alexandre', email: 'alexandre@gmail.com', password: 'azerty')
User.create(name: 'Lenny', email: 'lenny@gmail.com', password: 'azerty')
puts "Users created!"

# Create cities
puts "Creating cities..."
CITIES.each do |city|
  City.create!(
    name: city[:name],
    country: "France",
    population: city[:population]
  )
end
puts "Cities created!"

# Create stations
puts "Creating stations..."
city = City.all.first # For now, all stations are in Paris...
stations_store = {}
File.readlines("db/data/national_stations.ndjson")
    .each do |file_line|
      station = JSON.parse(file_line).deep_symbolize_keys
      new_station = Station.new(
        name: station[:name],
        latitude: station[:location][:latitude],
        longitude: station[:location][:longitude],
        db_stop_id: station[:id],
        city: city
      )
      stations_store[new_station.db_stop_id] = new_station.id if new_station.save
    end
puts "Stations created!"

# Create lines
puts "Creating lines..."
File.readlines("db/data/lines.ndjson").in_groups_of(1000) do |group|
  group.reject!(&:blank?)
  unless group.empty? || group.nil?
    group.map! do |file_line|
      line = JSON.parse(file_line.chomp).deep_symbolize_keys
      {
        station_start_id: stations_store[line[:station_start_db_stop_id]],
        station_end_id: stations_store[line[:station_end_db_stop_id]],
        dt_start: Time.parse(line[:dt_start]),
        dt_end: Time.parse(line[:dt_end]),
        duration: line[:duration],
        db_trip_id: line[:db_trip_id]
      }
    end.reject! do |line|
      line[:station_start_id].nil? || line[:station_end_id].nil?
    end
    Line.insert_all(group) unless group.empty?
  end
end
puts "Lines created!"

# Create journeys
puts "Creating journeys..."
Journey.create(name: 'bumble rumble', user_id: User.first.id, likes: 5, duration: 200, station_start_id: Station.last.id, station_end_id: Station.first.id)
Journey.create(name: 'balkan pigeon', user_id: User.first.id, likes: 5, duration: 200, station_start_id: Station.last.id, station_end_id: Station.last.id)
Journey.create(name: 'saucisse seche', user_id: User.first.id, likes: 5, duration: 200, station_start_id: Station.last.id, station_end_id: Station.first.id)
Journey.create(name: 'escapade entre potes', user_id: User.last.id, likes: 5, duration: 200, station_start_id: Station.first.id, station_end_id: Station.last.id)
Journey.create(name: 'tarte au thon', user_id: User.last.id, likes: 5, duration: 200, station_start_id: Station.first.id, station_end_id: Station.first.id)
Journey.create(name: 'scandinavie en amoureux', user_id: User.last.id, likes: 5, duration: 200, station_start_id: Station.first.id, station_end_id: Station.first.id)
puts "Journeys created!"

puts "--> Database seeded with #{User.count} users, #{City.count} cities, #{Station.count} stations, #{Line.count} lines and #{Journey.count} "
