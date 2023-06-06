class AddDurationToLines < ActiveRecord::Migration[7.0]
  def change
    add_column :lines, :duration, :integer
  end
end
