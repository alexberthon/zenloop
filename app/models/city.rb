class City < ApplicationRecord
  has_many :activities
  has_many :stations
  has_many :stays

  has_one_attached :photo
  reverse_geocoded_by :latitude, :longitude
end
