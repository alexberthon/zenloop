class ChangeTypeInSteps < ActiveRecord::Migration[7.0]
  def change
    rename_column :steps, :type, :kind
  end
end
