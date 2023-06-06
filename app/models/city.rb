class City < ApplicationRecord
  has_many :activities
  # has_many :stations
  has_many :stays


  geocoded_by :address
  # after_validation :geocode, if: :will_save_change_to_address?

  has_many :journeys_as_city_start_id, class_name: 'Journey', foreign_key: 'city_start_id', inverse_of: :city_start, dependent: :nullify
  has_many :journeys_as_city_end_id, class_name: 'Journey', foreign_key: 'city_end_id', inverse_of: :city_end, dependent: :nullify
end
