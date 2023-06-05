class CreateLines < ActiveRecord::Migration[7.0]
  def change
    create_table :lines do |t|
      t.references :station_start, null: false, foreign_key: { to_table: :stations }
      t.references :station_end, null: false, foreign_key: { to_table: :stations }
      t.datetime :dt_start
      t.datetime :dt_end

      t.timestamps
    end
  end
end
