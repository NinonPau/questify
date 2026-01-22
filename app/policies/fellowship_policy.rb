class FellowshipPolicy < ApplicationPolicy
  # Scope: only fellowships where the user is involved
  class Scope < Scope
    def resolve
      scope.where(
        "user_id = :user_id OR user_ally_id = :user_id",
        user_id: user.id
      )
    end
  end

  # Anyone logged in can see their own fellowships (handled by scope)
  def index?
    user.present?
  end

  # Any logged-in user can send a fellowship request
  def create?
    user.present?
  end

  # Only sender or receiver can update the fellowship
  def update?
    participant?
  end

  # Only sender or receiver can delete the fellowship
  def destroy?
    participant?
  end

  private

  # User is part of the fellowship (sender or receiver)
  def participant?
    record.user == user || record.ally == user
  end
end
