class AddUniqueIndexToFellowships < ActiveRecord::Migration[7.1]
  def change
    add_index :fellowships, [:user_id, :user_ally_id], unique: true # fail safe the same user–ally pair cannot exist more than once
  end
end
