class CreateMoods < ActiveRecord::Migration[7.1]
  def change
    create_table :moods do |t|
      t.references :user, null: false, foreign_key: true

      t.string :mood_type # Rails uses a column named type for Single Table Inheritance (STI), which is a feature that allows different models to share the same table. so i rename it mood_type 
      t.decimal :xp_bonus, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end
