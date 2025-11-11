class CreateUserMoods < ActiveRecord::Migration[7.1]
  def change
    create_table :user_moods do |t|
      t.references :user, null: false, foreign_key: true
      t.float :xp_bonus

      t.timestamps
    end
  end
end
