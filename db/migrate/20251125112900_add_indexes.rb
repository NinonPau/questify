class AddIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :hearth_participants, [:hearth_id, :user_id], unique: true
    add_index :quest_participants, [:quest_id, :fellowship_id], unique: true
  end
end
