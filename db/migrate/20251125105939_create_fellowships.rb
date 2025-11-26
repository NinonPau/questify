class CreateFellowships < ActiveRecord::Migration[7.1]
  def change
    create_table :fellowships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :user_ally, foreign_key: { to_table: :users }# user_ally is a reference to an other user 
      t.string :status

      t.timestamps
    end
  end
end
