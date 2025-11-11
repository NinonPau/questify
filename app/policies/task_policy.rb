class TaskPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # user see only his task and the one he his participating in 
      scope.joins("LEFT JOIN task_participants ON tasks.id = task_participants.task_id")
           .where("tasks.user_id = ? OR task_participants.user_id = ?", user.id, user.id)
           .distinct
    end
  end

  def show?
    record.user == user || record.participants.include?(user)
  end

  def create?
    user.present?
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  def complete?
    record.user == user
  end

  def ignore?
    record.user == user
  end

  def unignore?
    record.user == user
  end

  def invite_friend?
    record.user == user
  end

  def accept_invitation?
    record.participants.include?(user)
  end

  def decline_invitation?
    record.participants.include?(user)
  end
end
