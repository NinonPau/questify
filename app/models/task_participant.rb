class TaskParticipant < ApplicationRecord
  belongs_to :task
  belongs_to :user

  scope :accepted, -> { where(status: "accepted") }
  scope :pending, -> { where(status: "pending") }
  scope :declined, -> { where(status: "declined") }
end
