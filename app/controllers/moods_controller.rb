class UserMoodController < ApplicationController
  before_action :set_mood

  # POST /moods
  def create
    authorize Mood
    @mood = Mood.find_or_initialize_by(user: current_user)
    @mood.user = current_user
    if @mood.save
      redirect_to root_path, notice: "Mood set!"
    else
      redirect_to root_path, alert: "Failed to set Mood!"
    end
  end

  # PATCH /moods/:id
  def edit
    authorize @mood
    @mood = Mood.find(params[:id])
  end

  # PATCH /moods/:id
  def update
    authorize @mood
    @mood = Mood.find(params[:id])
    @mood.xp_bonus = set_xp_bonus
    @mood.update(strong_params)
    # @mood.save
    redirect_to root_path
  end

  private
  def set_mood
    @mood = Mood.find(params[:id])
  end

end
