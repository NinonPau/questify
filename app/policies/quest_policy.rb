class QuestPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
    def resolve
      scope
        .left_joins(quest_participants: :fellowship)# check doc Pundit for quest 
        .where(
          #Only match quests where the quest’s owner is the current user.(l18) => the quest the current user created
          #OR The fellowship must be accepted AND The user must be one of the two users in that fellowship
          #If we removed the parentheses, SQL could interpret the logic incorrectly.Parentheses ensure the logic is grouped correctly.
          "quests.user_id = :user_id 
           OR (
             fellowships.status = :accepted
             AND (fellowships.user_id = :user_id OR fellowships.user_ally_id = :user_id)
           )",
          user_id: user.id, #Replace :user_id with the current user’s ID.
          accepted: "accepted"#Replace :accepted with the string "accepted".
        )
        .distinct #Remove duplicate rows from the result. when joins and left_joins are used, 
        #it's possible to get duplicate records if a quest has multiple participants. 
        #distinct ensures that each quest appears only once in the result set.
    end
  end

  def index?#“Is this action allowed?” 
    true#Any logged-in user is allowed to access the index action. then he run scope to get only quests that are visible to him
  end

  def show?#controls whether a user can access: GET /quests/:id - checks authorization for one specific record.
    owner? || invited_as_ally? #The user is the owner of the quest OR The user is invited as an ally to the quest (via a fellowship)
  end
  # different from index because index checks if the user can see the list of quests, while show checks if the user can see a specific quest.

  def create?
    true
  end

  def new?
    create?#If a user is allowed to create a quest,they should also be allowed to see the form to create one so we call create? to avoid duplicating the logic. 
    #If we change the logic in create?, it will automatically apply to new? as well.
  end

  def update?
    owner?
  end

  def edit?
    update?
  end

  def destroy?
    owner?
  end

  private

  def owner?
    record.user_id == user.id #The ID of the user who owns this quest.==The ID of the current user. This checks if the current user is the owner of the quest.
  end

  def invited_as_ally?
    # Ally can see the quest only if:
    # - there is a quest_participant linking the quest to a fellowship
    # - the fellowship is accepted
    # - the current user belongs to that fellowship
    # - Does at least one record matching this condition exist in the database?
    record.quest_participants
          .joins(:fellowship)
          .where(fellowships: { status: "accepted" })
          .where("fellowships.user_id = :id OR fellowships.user_ally_id = :id", id: user.id)
          .exists?
  end
end
