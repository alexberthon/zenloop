class PagesController < ApplicationController
  def home
    @stations = Station.all
    @journey = Journey.new
  end
end
