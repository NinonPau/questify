class UserMoodController < ApplicationController
  # before_action :authenticate_user! ##if implemented##

  def create
    @mood = Mood.new(strong_params)
    @mood.user = current_user
    if @mood.save
      redirect_to root_path
    else
      render :home, status: :unprocessable_entity
    end
  end

  def edit
    @mood = Mood.find(params[:id])
  end

  def update
    @mood = Mood.find(params[:id])
    @mood.xp_bonus = set_xp_bonus
    @mood.update(strong_params)
    # @mood.save
    redirect_to root_path
  end

  private

  def set_xp_bonus
    case @mood.mood_type
    when "Amazing" then 1.25
    when "Good" then 1.50
    when "Ok'ish" then 2.00
    when "Bad" then 3.00
    end
  end

  def strong_params
    params.require(:mood).permit(:mood_type, :xp_bonus, :date)
  end

end
