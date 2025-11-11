class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :description
      t.boolean :daily
      t.boolean :completed
      t.float :xp
      t.date :date
      t.boolean :ignored
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
