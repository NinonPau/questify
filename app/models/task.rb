class Task < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :task_participants, dependent: :destroy
  has_many :participants, through: :task_participants, source: :user

  # Callbacks
  after_create :add_creator_as_participant

  # Validations
  # Ensure that every task has a name and that XP is not negative
  validates :name, presence: true
  validates :xp, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Instance Methods
  # add creator of the task as user 
  def add_creator_as_participant
    task_participants.find_or_create_by(user: user, status: "accepted")
  end
  # Check if the task is scheduled for today
  def today?
    date == Date.today
  end

  # Add the task creator automatically as an accepted participant
  def add_creator_as_participant
    task_participants.find_or_create_by(user: user, status: "accepted")
  end

  # Check if a specific user has accepted an invitation to this task
  def invitation_accepted_by?(user)
    task_participants.exists?(user: user, status: "accepted")
  end

  # Class Methods

  # Reset daily tasks for today:
  # - Delete old tasks (not for today)
  # - Recreate daily tasks for each user
  def self.reset_for_today
    # Delete all tasks not from today
    Task.where.not(date: Date.today).destroy_all

    # Recreate daily tasks for every user
    User.find_each do |user|
      user.tasks.where(daily: true).each do |daily_task|
        user.tasks.create(
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
