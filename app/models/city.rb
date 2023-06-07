class City < ApplicationRecord
  has_many :activities
  has_many :stations
  has_many :stays
end
