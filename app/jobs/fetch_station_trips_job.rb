require "json"
require "open-uri"

DB_BASE_URL = "http://localhost:3001"
DELAY = 0
DEPARTURES_PER_STATION = 1000
DATE = URI.encode_www_form_component(Time.now.next_day.beginning_of_day.strftime("%Y-%m-%dT%H:%M:%S%:z"))

class FetchStationTripsJob < ApplicationJob
  queue_as :default

  def perform(station)
    trips = fetch_trips(station, DEPARTURES_PER_STATION)
    trips.each_with_index do |trip_id, index|
      # sleep(DELAY)
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
          dt_end: Time.parse(stopover[:arrival]),
          db_trip_id: trip_id
        )
        line.duration = ((line.dt_end - line.dt_start) / 60).to_i
        line.save
      end
    end
  end

  private

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
end
