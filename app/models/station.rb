class Station < ApplicationRecord
  belongs_to :city
  has_many :lines_as_station_start, class_name: "Line", foreign_key: :station_start_id, inverse_of: :station_start,
                                    dependent: :destroy
  has_many :lines_as_station_end, class_name: "Line", foreign_key: :station_end_id, inverse_of: :station_end,
                                  dependent: :destroy

  validates :db_stop_id, uniqueness: true
  def self.to_select
    all.map { |station| [station.name] }
  end
end
