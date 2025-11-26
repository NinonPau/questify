class HearthParticipant < ApplicationRecord
  # ASSOCIATIONS

  # The hearth the user is joining
  belongs_to :hearth
  # The user who participates in the hearth
  belongs_to :user
  # VALIDATIONS
  # Ensure a user can join the same hearth ONLY once
  # Example: prevents duplicates like (hearth_id=3, user_id=7) twice
  validates :user_id, uniqueness: { scope: :hearth_id }


end
