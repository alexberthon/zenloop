class AddDbTripIdToLines < ActiveRecord::Migration[7.0]
  def change
    add_column :lines, :db_trip_id, :string
  end
end
