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

  # PUBLIC METHODS

  # register the quest owner automatically
  # This method ensures the quest owner is registered as a participant.
  # It uses a special "self_fellowship" representing the user with themselves.( find it in user.rb)
  def add_creator_as_participant
    # Retrieve (or create) the fellowship linking the user to themselves.
    creator_fellowship = user.self_fellowship

    # Find an existing quest_participant for that fellowship,
    # or initialize a new one if it does not exist.
    qp = quest_participants.find_or_initialize_by(fellowship: creator_fellowship)

    # Force the status to accepted, since the owner automatically participates.
    qp.status = "accepted"

    # Save the quest_participant record.
    qp.save!
  end
  # Invites an ally to help on this quest.
  # This method encapsulates the business logic of sending a help request.
  def invite_ally!(owner:, ally:)
    # Find the accepted fellowship between the owner and the ally.
    fellowship = accepted_fellowship_between(owner, ally)

    # If no accepted fellowship exists, raising an error prevents invitation.
    raise ArgumentError, "Ally relationship is not accepted" unless fellowship

    # Find or initialize the quest_participant linking this fellowship to the quest.
    qp = quest_participants.find_or_initialize_by(fellowship: fellowship)

    # Set the invitation status to pending.
    qp.status = "pending"

    # Save the quest_participant record.
    qp.save!
  end

  # Invite multiple allies to help on this quest.
  # Reuses the single-invite logic for each ally.
  def invite_allies!(owner:, allies:)
    allies.each do |ally|
      invite_ally!(owner: owner, ally: ally)
    end
  end

  private

  # Finds the accepted fellowship between two users.
  # It checks both possible directions of the relationship.
  def accepted_fellowship_between(a, b)
    Fellowship
      # Only consider accepted relationships.
      .where(status: "accepted")
      # Check both (a - b) and (b - a).
      .where(
        "(user_id = :a AND user_ally_id = :b) OR (user_id = :b AND user_ally_id = :a)",
        a: a.id,
        b: b.id
      )
      .first
  end

end
