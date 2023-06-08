class ChangeColumnsNullInSteps < ActiveRecord::Migration[7.0]
  def change
    change_column_null :steps, :line_id, true
    change_column_null :steps, :stay_id, true
  end
end
