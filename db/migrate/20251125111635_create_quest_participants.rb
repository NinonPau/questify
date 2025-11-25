class CreateQuestParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :quest_participants do |t|
      t.references :fellowship, null: false, foreign_key: true
      t.references :quest, null: false, foreign_key: true
      t.string :status, default: "pending"

      t.timestamps
    end

    add_index :quest_participants, [:fellowship_id, :quest_id], unique: true # avoid adding the same allies more than once to a quest 
  end
end
