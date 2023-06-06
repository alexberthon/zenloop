class Line < ApplicationRecord
  has_many :stations
#   belongs_to :station_start_id, class_name: 'Station', inverse_of: :lines_as_station_start_id
#   belongs_to :station_end_id, class_name: 'Station', inverse_of: :lines_as_station_end_id
end
