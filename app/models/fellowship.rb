class Fellowship < ApplicationRecord
  # ASSOCIATIONS
  # The user who SENT the ally request
  belongs_to :user

  # The user who RECEIVED the ally request
  belongs_to :ally,
    class_name: "User",
    foreign_key: "user_ally_id"

  # Quest participation linking quests <-> fellowships
  has_many :quest_participants, dependent: :destroy
  has_many :quests, through: :quest_participants

  # VALIDATIONS

  # Prevent duplicate links:
  # You cannot have two fellowships with the same (user_id + user_ally_id)
  validates :user_ally_id, uniqueness: { scope: :user_id }

  # STATUS
  # status is stored as a string in DB
  enum status: {
    pending:  "pending",
    accepted: "accepted",
    declined: "declined"
  }


end
