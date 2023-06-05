class Journey < ApplicationRecord
  belongs_to :user
  belongs_to :city_start_id, class_name: 'City', inverse_of: :journeys_as_city_start_id
  belongs_to :city_end_id, class_name: 'City', inverse_of: :journeys_as_city_end_id

  has_many :steps
end
