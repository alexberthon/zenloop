class Line < ApplicationRecord
  belongs_to :station_start, class_name: "Station", inverse_of: :lines_as_station_start
  belongs_to :station_end, class_name: "Station", inverse_of: :lines_as_station_end

  validates :duration, presence: true
  validates :station_start, uniqueness: { scope: :station_end }
end
