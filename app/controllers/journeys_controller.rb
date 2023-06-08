class JourneysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journey, only: %i[show]

  def index
    @journeys = Journey.all
  end

  def show
    @journey = Journey.find(params[:id])
    @station = @journey.station_start
    @stations = Station.all
    @lines = Line.where(station_start: @station).includes(:station_end)

    @reachable_stations = geojson_reachable(@lines)
    @selected_stations = geojson_selected([@station])

    trips = @lines.group_by(&:db_trip_id) # hash of arrays
    @strokes = geojson_trips(@station, trips)
  end

  def create
    @station_start = Station.find(journey_params[:station_start_id])
    @journey = Journey.new(
      station_start: @station_start,
      station_end: @station_start,
      user: current_user,
      name: "trip starting from " + @station_start.name
    )
    if @journey.save!
      redirect_to journey_path(@journey)
    else
      render "pages/home", status: :unprocessable_entity
    end
  end

  private

  def journey_params
    params.require(:journey).permit(:station_start_id)
  end

  def set_journey
    @journey = Journey.find(params[:id])
  end

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
end
