class AddDefaultValuesToQuestsBooleans < ActiveRecord::Migration[7.1]
  def change
    change_column_default :quests, :daily, from: nil, to: false
    change_column_default :quests, :completed, from: nil, to: false
    change_column_default :quests, :frozen, from: nil, to: false
  end
end
