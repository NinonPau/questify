class CreateUserMoods < ActiveRecord::Migration[7.1]
  def change
    create_table :user_moods do |t|

      t.timestamps
    end
  end
end
