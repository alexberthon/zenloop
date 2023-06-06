class AddDbStopIdToStations < ActiveRecord::Migration[7.0]
  def change
    add_column :stations, :db_stop_id, :string
  end
end
