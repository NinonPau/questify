class CreateQuests < ActiveRecord::Migration[7.1]
  def change
    create_table :quests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.boolean :daily
      t.boolean :completed
      t.boolean :frozen
      t.integer :xp
      t.date :date

      t.timestamps
    end
  end
end
