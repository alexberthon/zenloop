class Journey < ApplicationRecord
  belongs_to :user
  belongs_to :station_start, class_name: 'Station', inverse_of: :journeys_as_station_start
  belongs_to :station_end, class_name: 'Station', inverse_of: :journeys_as_station_end

  has_many :steps, -> { order("position ASC") }, dependent: :destroy
  has_many :cities
  has_many :activities
  has_many :likes, dependent: :destroy

  has_one_attached :photo

  def total_distance
    distances = self.steps.map do |step|
      step.distance
    end
    distances.sum
  end
end
