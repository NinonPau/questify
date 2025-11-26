class Hearth < ApplicationRecord

  # ASSOCIATIONS

  # The user who created the hearth
  belongs_to :user
  # Each hearth can have many participants through HearthParticipant
  has_many :hearth_participants, dependent: :destroy
  # Shortcut to access users who joined the hearth
  has_many :participants, through: :hearth_participants, source: :user
  # Messages posted inside the hearth
  has_many :messages, dependent: :destroy
  # VALIDATIONS
  # A hearth must have a name
  validates :name, presence: true
end
