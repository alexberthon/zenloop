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
    # @strokes = geojson_lines(@station, @lines.map(&:station_end))
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
      json.type "geojson"
      json.data do
        json.type "FeatureCollection"
        json.features stations do |station|
          json.type "Feature"
          json.properties do
            json.name station.name
          end
          json.geometry do
            json.type "Point"
            json.coordinates [station.longitude, station.latitude]
          end
        end
      end
    end.attributes!.to_json
  end

  def geojson_reachable(lines)
    Jbuilder.new do |json|
      json.type "geojson"
      json.data do
        json.type "FeatureCollection"
        json.features lines do |line|
          json.type "Feature"
          json.properties do
            json.name line.station_end.name
            json.duration line.duration
          end
          json.geometry do
            json.type "Point"
            json.coordinates [line.station_end.longitude, line.station_end.latitude]
          end
        end
      end
    end.attributes!.to_json
  end

  def geojson_trips(station_start, trips)
    Jbuilder.new do |json|
      json.type "geojson"
      json.data do
        json.type "FeatureCollection"
        json.features trips.values do |trip|
          json.type "Feature"
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
      end
    end.attributes!.to_json
  end

  def geojson_lines(station_start, reachable_stations)
    Jbuilder.new do |json|
      json.type "geojson"
      json.data do
        json.type "FeatureCollection"
        json.features reachable_stations do |reachable_station|
          json.type "Feature"
          json.geometry do
            json.type "LineString"
            json.coordinates [[station_start.longitude, station_start.latitude],
                              [reachable_station.longitude, reachable_station.latitude]]
          end
        end
      end
    end.attributes!.to_json
  end
end
