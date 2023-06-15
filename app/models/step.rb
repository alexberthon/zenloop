class Step < ApplicationRecord
  belongs_to :journey
  belongs_to :line, optional: true
  belongs_to :stay, optional: true

  acts_as_list scope: :journey

  def distance
    kind == "line" ?
      (Geocoder::Calculations.distance_between([ line.station_start.latitude, line.station_start.longitude],[ line.station_end.latitude, line.station_end.longitude])).round() : 0
  end
end
