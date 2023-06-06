class City < ApplicationRecord
  has_many :activities
  has_many :stations
  has_many :stays

  has_many :journeys_as_city_start, class_name: "Journey", foreign_key: :city_start_id, inverse_of: :city_start, dependent: :destroy
  has_many :journeys_as_city_end, class_name: "Journey", foreign_key: :city_end_id, inverse_of: :city_end, dependent: :destroy
end
