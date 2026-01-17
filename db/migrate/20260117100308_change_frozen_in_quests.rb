class ChangeFrozenInQuests < ActiveRecord::Migration[7.1]
  def change
    rename_column :quests, :frozen, :ignored
  end
end
