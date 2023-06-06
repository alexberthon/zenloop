class Journey < ApplicationRecord
  belongs_to :user
  belongs_to :city_start, class_name: 'City', inverse_of: :journeys_as_city_start
  belongs_to :city_end, class_name: 'City', inverse_of: :journeys_as_city_end

  has_many :steps
  has_many :cities
end
