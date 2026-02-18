class RenameFrozenToPausedInQuests < ActiveRecord::Migration[7.1]
  def change
    rename_column :quests, :frozen, :paused
  end
end
