class Journey < ApplicationRecord
  belongs_to :user
  belongs_to :station_start, class_name: 'Station', inverse_of: :journeys_as_station_start
  belongs_to :station_end, class_name: 'Station', inverse_of: :journeys_as_station_end

  has_many :steps, -> { order("position ASC") }, dependent: :destroy
  has_many :cities
  has_many :activities
  has_many :likes, dependent: :destroy
end
