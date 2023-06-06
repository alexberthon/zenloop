class AddDurationToStays < ActiveRecord::Migration[7.0]
  def change
    add_column :stays, :duration, :integer
  end
end
