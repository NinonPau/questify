class QuestPolicy < ApplicationPolicy
  # BASIC ACTIONS
  # can the user see the quests list?
  def index?
    user.present?   # must be logged in
  end

  # can the user see a specific quest?
  def show?
    owner? || invited?  # either creator OR participant
  end

  # same as create?
  def new?
    create?
  end

  # can the user create a quest?
  def create?
    user.present? # any logged user can
  end

  # can the user update a quest?
  def update?
    owner? # only the quest creator
  end

  # edit? is always alias for update? in policies
  def edit?
    update?
  end

  # can the user delete a quest?
  def destroy?
    owner?  # only the quest creator
  end




  # SCOPE
  # What quests appear in Quest#index ?


  class Scope < Scope
    def resolve

      # 1) quests created by the user
      mine = scope.where(user_id: user.id)

      # 2) quests where user participates
      invited = scope
        .joins(:quest_participants)# inner join
        .where(quest_participants: {
          fellowship_id: user.fellowships# only quests connected to his fellowships
        })

      # return both matched categories
      mine.or(invited).distinct
    end
  end

  # HELPERS

  private

  # is the user the quest owner?
  def owner?
    record.user_id == user.id
    # record = Quest instance
    # user   = current_user
  end

  # is the user invited via quest_participants?
  def invited?
    record.quest_participants.exists?(
      fellowship_id: user.fellowships
    )
  end

end
