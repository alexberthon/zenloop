class AddTrainlineToStations < ActiveRecord::Migration[7.0]
  def change
    add_column :stations, :trainline, :string
  end
end
