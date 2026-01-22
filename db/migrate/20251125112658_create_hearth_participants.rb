class CreateHearthParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :hearth_participants do |t|
      t.references :hearth, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
