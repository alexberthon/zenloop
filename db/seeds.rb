require "json"
require "csv"

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
Like.destroy_all
puts "Likes destroyed!"

puts "Destroying users..."
User.destroy_all
puts "Users destroyed!"

puts "Destroying stations..."
Station.destroy_all
puts "Stations destroyed!"

puts "Deleting cities..."
City.delete_all
puts "Cities deleted!"

puts ""
puts "---------- CREATE ----------"
puts ""

# Create users
puts "Creating users..."
User.create(name: 'Alexis', email: 'alexis@gmail.com', password: 'azerty')
User.create(name: 'Antoine', email: 'antoine@gmail.com', password: 'azerty')
User.create(name: 'Alexandre', email: 'alexandre@gmail.com', password: 'azerty')
User.create(name: 'Lenny', email: 'lenny@gmail.com', password: 'azerty')
User.create(name: 'likerbot', email: 'likerbot@gmail.com', password: 'azerty')

puts "Users created!"

# Create cities
puts "Creating cities..."
CSV.readlines("db/data/cities.csv", headers: :first_rown, col_sep: ";").to_a.drop(1).in_groups_of(1000) do |group|
  group = group.compact
  group.map! do |row|
    coordinates = row[19].split(",").map(&:strip).map(&:to_f)
    {
      name: row[1],
      country_code: row[6],
      country: row[7],
      population: row[13],
      latitude: coordinates[0],
      longitude: coordinates[1]
    }
  end
  City.insert_all(group) unless group.empty?
end
puts "Cities created!"

# Create stations
puts "Creating stations..."
stations_store = {}
File.readlines("db/data/national_stations.ndjson")
    .each do |file_line|
      station = JSON.parse(file_line).deep_symbolize_keys
      new_station = Station.new(
        name: station[:name],
        latitude: station[:location][:latitude],
        longitude: station[:location][:longitude],
        db_stop_id: station[:id]
      )
      new_station.city = City.near([new_station.latitude, new_station.longitude], 50).first
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
Journey.create(name: 'Balkan Rumble', user_id:User.all.sample.id, duration: rand(1000), station_start_id: Station.all.sample.id, station_end_id:  Station.all.sample.id)
Journey.create(name: 'Escapade Romantique', user_id:User.all.sample.id, duration: rand(1000), station_start_id:  Station.all.sample.id, station_end_id:  Station.all.sample.id)
Journey.create(name: 'Weekend entre potes', user_id:User.all.sample.id, duration: rand(1000), station_start_id:  Station.all.sample.id, station_end_id:  Station.all.sample.id)
Journey.create(name: 'Summer 2024', user_id: User.all.sample.id, duration: rand(1000), station_start_id:  Station.all.sample.id, station_end_id:  Station.all.sample.id)
Journey.create(name: 'EVJF Margaux', user_id: User.all.sample.id, duration: rand(1000), station_start_id:  Station.all.sample.id, station_end_id:  Station.all.sample.id)
Journey.create(name: 'Scandinavie en amoureux', user_id: User.all.sample.id, duration: rand(1000), station_start_id:  Station.all.sample.id, station_end_id:  Station.all.sample.id)
puts "Journeys created!"



#Create likes
100.times do
Like.create(user_id: User.last.id, journey_id: Journey.all.sample.id)
end

puts "--> Database seeded with #{User.count} users, #{City.count} cities, #{Station.count} stations, #{Line.count} lines, #{Like.count} likes and #{Journey.count} journeys "
