class RenameOrderInSteps < ActiveRecord::Migration[7.0]
  def change
    rename_column :steps, :order, :position
  end
end
