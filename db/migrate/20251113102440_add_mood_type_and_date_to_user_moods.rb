class AddMoodTypeAndDateToUserMoods < ActiveRecord::Migration[7.1]
  def change
    add_column :user_moods, :mood_type, :string, default: "Not selected"
    add_column :user_moods, :date, :date

  end
end
