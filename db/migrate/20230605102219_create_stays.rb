class CreateStays < ActiveRecord::Migration[7.0]
  def change
    create_table :stays do |t|
      t.datetime :dt_start
      t.datetime :dt_end
      t.references :city, null: false, foreign_key: true

      t.timestamps
    end
  end
end
