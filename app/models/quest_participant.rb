class QuestParticipant < ApplicationRecord
  belongs_to :fellowship
  belongs_to :quest

  enum status: {
    pending: "pending",
    accepted: "accepted",
    declined: "declined"
  }

  validates :fellowship_id, uniqueness: { scope: :quest_id }
end
