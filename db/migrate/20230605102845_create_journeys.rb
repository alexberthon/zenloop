class CreateJourneys < ActiveRecord::Migration[7.0]
  def change
    create_table :journeys do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.integer :likes
      t.references :city_start, null: false, foreign_key: { to_table: :cities }
      t.references :city_end, null: false, foreign_key: { to_table: :cities }
      t.integer :duration

      t.timestamps
    end
  end
end
