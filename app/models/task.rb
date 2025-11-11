class Task < ApplicationRecord
  belongs_to :user
  has_many :task_participants, dependent: :destroy
  has_many :participants, through: :task_participants, source: :user

  after_create :add_creator_as_participant
  after_initialize :set_defaults, if: :new_record?

  #  Validations
  validates :name, presence: true
  validates :xp, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes (avoid Task.where(date: Date.today) for RESTful clarity)
  scope :today, -> { where(date: Date.today) }
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }

  # Instance Methods (handle task logic make the controller more readable)
    # Task mark as completed + reward participants
  def today?
    date == Date.today
  end

  def set_defaults
    self.date ||= Date.today
  end
  
  def complete!
    update(completed: true)
    add_creator_as_participant
    reward_participants
  end

  def reward_participants
    task_participants.accepted.each do |tp|
      tp.user.add_xp(xp.to_i)
    end
  end
  # Invitation management
  def invite(user)
    participant = task_participants.find_or_initialize_by(user: user)
    participant.status = "pending"
    participant.save
  end

  def accept_invitation(user)
    participant = task_participants.find_by(user: user)
    participant&.update(status: "accepted")
  end

  def decline_invitation(user)
    participant = task_participants.find_by(user: user)
    participant&.update(status: "declined")
  end
  # Invitation status checks
  def invited?(user)
    task_participants.exists?(user: user)
  end

  def accepted_by?(user)
    task_participants.exists?(user: user, status: "accepted")
  end

  def add_creator_as_participant
    task_participants.find_or_create_by(user: user, status: "accepted")
  end

  # reset daily tasks for a new day

  def self.reset_for_today
    Task.where.not(date: Date.today).destroy_all
    User.find_each do |user|
      user.tasks.where(daily: true).find_each do |daily_task|
        user.tasks.create!(
          name: daily_task.name,
          description: daily_task.description,
          daily: true,
          xp: daily_task.xp,
          completed: false,
          date: Date.today
        )
      end
    end
  end
end
