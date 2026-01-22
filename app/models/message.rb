class Message < ApplicationRecord
  # ASSOCIATIONS
  # who posted the message
  belongs_to :user

  # where the message was posted
  belongs_to :hearth

  # VALIDATIONS
  validates :content, presence: true
end
