class JourneysController < ApplicationController
  # before_action :authenticate_user!

  def index
    @journeys = Journey.all
  end

  def show
  end

  def new
  end

  def create
  end

  def update
  end
end
