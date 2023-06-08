class PagesController < ApplicationController
  def home
    @stations = Station.all
    @journey = Journey.new
    @journeys = Journey.all
  end
end
