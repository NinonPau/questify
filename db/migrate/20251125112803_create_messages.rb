class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :hearth, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.text :content, null: false

      t.timestamps
    end
  end
end
