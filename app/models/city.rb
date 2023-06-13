class City < ApplicationRecord
  has_many :activities
  has_many :stations, dependent: :destroy
  has_many :stays, dependent: :destroy

  has_one_attached :photo
  reverse_geocoded_by :latitude, :longitude
end
