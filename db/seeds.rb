User.destroy_all
Line.destroy_all
Station.destroy_all
City.destroy_all

puts "Seeding database..."

User.create(name: 'Alexis', email: 'alexis@gmail.com', password: 'azerty')
User.create(name: 'Antoine', email: 'antoine@gmail.com', password: 'azerty')
User.create(name: 'Alexandre', email: 'alexandre@gmail.com', password: 'azerty')
User.create(name: 'Lenny', email: 'lenny@gmail.com', password: 'azerty')

paris = City.create(name: "Paris", country: "France", population: 2000)
lyon = City.create(name: "Lyon", country: "France", population: 1000)
marseille = City.create(name: "Marseille", country: "France", population: 3000)

parisnord = Station.create(name: "gare du nord", city_id: paris.id, address: "18 Rue de Dunkerque, 75010 Paris")
parisest = Station.create(name: "gare de l'est", city_id: paris.id, address: "Rue du 8 Mai 1945, 75010 Paris")
parislyon = Station.create(name: "gare de lyon", city_id: paris.id, address: "Pl. Louis-Armand, 75012 Paris")
partdieu = Station.create(name: "gare lyon part-dieu", city_id: lyon.id, address: "5, place Charles Béraudier 69003 Lyon")
saintcharles = Station.create(name: "gare marseille saint-charles", city_id: marseille.id, address: "Square Narvik 13232 Marseille")

Line.create(station_start_id: parislyon.id, station_end_id: saintcharles.id)
Line.create(station_start_id: saintcharles.id, station_end_id: parislyon.id)
Line.create(station_start_id: parislyon.id, station_end_id: partdieu.id)
Line.create(station_start_id: partdieu.id, station_end_id: parislyon.id)

puts "--> Database seeded with #{User.count} users, #{City.count} cities, #{Station.count} stations and #{Line.count} lines"
