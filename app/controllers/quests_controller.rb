class QuestsController < ApplicationController
  before_action :authenticate_user!
  def index 
    # Only quests the user is allowed to see (Pundit Scope)
    scoped = policy_scope(Quest).includes(quest_participants:{fellowship: [:user, :ally]})# avoid N+1 queries for participants and their fellowships and users
    # Visible quests for today
    @todays_quests = scoped.where(date: Date.today).distinct
    #today quests that are completed
    @completed_todays_quests = @todays_quests.where(completed: true)
     # Today quests that are NOT completed (active list)
    @active_todays_quests = @todays_quests.where(completed: false)
    # quests that are frozen (paused)
    @paused_quests = scoped.where(paused: true).distinct
    # Invitations: quests where current_user has a pending invitation
    # (meaning a QuestParticipant exists and is pending)
    # it is similar to policy but here serve the purpose of categorise the visable quests in the index page
    @pending_invitations = scoped
      .joins(quest_participants: :fellowship)
      .where(quest_participants: { status: "pending" })
      .where("fellowships.user_id = :id OR fellowships.user_ally_id = :id", id: current_user.id)
      .distinct # avoid duplicates
  end
 def new  
 end
 def edit 
 end
end
