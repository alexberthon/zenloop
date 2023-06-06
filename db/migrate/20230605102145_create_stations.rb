class CreateStations < ActiveRecord::Migration[7.0]
  def change
    create_table :stations do |t|
      t.string :name
      t.references :city, null: false, foreign_key: true
      t.float :latitude
      t.float :longitude
      t.timestamps
    end
  end
end
