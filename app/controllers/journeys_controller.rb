class JourneysController < ApplicationController
  before_action :authenticate_user!
  def index
    @search = params["search"]
    @stations = Station.all
    @journeys = Journey.all
    @steps = Step.all
    @cities = City.all
  end

    # if @search.present?
    #   @name = @search["name"]
    #   @querystation = Station.find_by(name: @name)
    #   @selected_station = Station.where(["id = #{@querystation.id}"])
    # end

    # @markers = @selected_station.map do |station|
    #   {
    #     lat: station.latitude,
    #     lng: station.longitude
    #   }
    # end

  def show
    @station = Station.find(params[:id])
    @journey = Journey.find(params[:id])
  end

end
