class ChangeReferencesInJourneys < ActiveRecord::Migration[7.0]
  def change
    remove_reference :journeys, :city_start, null: false, foreign_key: { to_table: :cities }
    remove_reference :journeys, :city_end, null: false, foreign_key: { to_table: :cities }
    add_reference :journeys, :station_start, null: false, foreign_key: { to_table: :stations }
    add_reference :journeys, :station_end, null: false, foreign_key: { to_table: :stations }
  end
end
