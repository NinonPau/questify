class AddTotalXpToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :total_xp, :float
  end
end
