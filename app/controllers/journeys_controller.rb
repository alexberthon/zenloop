class JourneysController < ApplicationController
  before_action :authenticate_user!
  def index
    @search = params["search"]
    @stations = Station.all
    @journeys = Journey.all
    @steps = Step.all
    @cities = City.all
  end

  def show
    @station = Station.find(params[:id])
    @journey = Journey.find(params[:id])
  end

end
