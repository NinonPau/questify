class QuestParticipant < ApplicationRecord
  # ASSOCIATIONS

  # Each participation belongs to a fellowship (link between two users).
  belongs_to :fellowship

  # Each participation belongs to a quest.
  belongs_to :quest


  # ENUMS

  # Status tracks the invitation lifecycle for this fellowship on this quest.
  enum status: {
    pending: "pending",
    accepted: "accepted",
    declined: "declined"
  }


  # VALIDATIONS

  # Prevent duplicate invitations for the same fellowship on the same quest.
  validates :fellowship_id, uniqueness: { scope: :quest_id }


  # PUBLIC METHODS

  # Accept the invitation.
  # Raises ActiveRecord::RecordInvalid if not true.
  # allow to pin where the error is coming from
  def accept!
    update!(status: "accepted")
  end

  # Decline the invitation.
  # Raises if the record is invalid.
  def decline!
    update!(status: "declined")
  end

  # Re-send / reset to pending.
  # Useful if you want to re-invite someone after a decline.
  def mark_pending!
    update!(status: "pending")
  end

  # Returns true if the given user is part of this fellowship.
  # This is useful for authorization checks in policies.
  def involves_user?(user)
    fellowship.user_id == user.id || fellowship.user_ally_id == user.id
  end
end
