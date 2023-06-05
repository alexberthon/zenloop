class Station < ApplicationRecord
  belongs_to :city

  has_many :lines_as_station_start_id, class_name: 'Line', foreign_key: 'station_start_id', inverse_of: :station_start, dependent: :nullify
  has_many :lines_as_station_end_id, class_name: 'Line', foreign_key: 'station_end_id', inverse_of: :station_end, dependent: :nullify
end
