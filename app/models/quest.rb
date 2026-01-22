class Quest < ApplicationRecord
  # ASSOCIATIONS
  # Owner of the quest
  belongs_to :user

  # People participating through fellowships
  has_many :quest_participants, dependent: :destroy
  has_many :fellowships, through: :quest_participants

  # VALIDATIONS
  validates :name, presence: true
  validates :xp, numericality: { greater_than_or_equal_to: 0 }

  # CALLBACKS
  # When the quest is created, make sure the creator is a participant
  after_create :add_creator_as_participant

  # PUBLIC INSTANCE METHODS

  # register the quest owner automatically
  def add_creator_as_participant
    creator_fellowship = user.self_fellowship

    quest_participants.find_or_create_by(
      fellowship: creator_fellowship,
      status: "accepted"
    )
  end
  
end
