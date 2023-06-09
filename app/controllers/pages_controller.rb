class PagesController < ApplicationController
  def home
    @journey = Journey.new
    @journeys = Journey.all
  end
end
