class CreateSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :steps do |t|
      t.integer :order
      t.references :journey, null: false, foreign_key: true
      t.string :type
      t.references :line, null: false, foreign_key: true
      t.references :stay, null: false, foreign_key: true
      t.integer :duration

      t.timestamps
    end
  end
end
