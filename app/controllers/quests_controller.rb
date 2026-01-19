class QuestsController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_quest, only: [:new, :create]

  def new
    @quest = current_user.quests.new
  end

  def create
    @quest = current_user.quests.new(quest_params)

    if @quest.save
      redirect_to root_path, notice: 'Quest was successfully created.'
      raise
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_quest
    @quest = Quest.find(params[:id]) if params[:id].present?
  end

  def quest_params
    params.require(:quest).permit(:name, :description, :daily, :completed, :frozen, :xp, :date)
  end
end
