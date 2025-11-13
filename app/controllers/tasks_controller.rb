require "json"
require "open-uri"

class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [
    :edit, :update, :complete,
    :ignore, :unignore,
    :invite_friend, :accept_invitation, :decline_invitation
  ]

  # INDEX
  def index
    # Tasks created by the current user for today
    @tasks = current_user.tasks.where(date: Date.today)

    # Tasks where the current user is a participant (pending or accepted)
    participant_records = current_user.task_participants.where(status: ["pending", "accepted"])

    # Gather all tasks where the user is participating
    @participating_tasks = participant_records.map(&:task)
  end

  # NEW
  def new
    @task = current_user.tasks.new
  end

  # CREATE
  def create
    @task = current_user.tasks.new(task_params)
    @task.date = Date.today

    if @task.save
      # Ensure creator is automatically marked as accepted participant
      @task.add_creator_as_participant
      redirect_to tasks_path, notice: "Quest successfully created!"
    else
      flash.now[:alert] = "Failed to create quest."
      render :new, status: :unprocessable_entity
    end
  end

  #  RANDOM
  # Create a random quest using the external API (Bored API)
  def random
    url = "https://bored.api.lewagon.com/api/activity"
    activity_serialized = URI.parse(url).read
    activity = JSON.parse(activity_serialized)

    @task = current_user.tasks.new(
      name: activity["activity"],
      description: "Type: #{activity["type"]} - Participants: #{activity["participants"]}" \
                   "#{' - Link: ' + activity["link"] if activity["link"].present?}",
      xp: 20,
      date: Date.today
    )

    if @task.save
      redirect_to tasks_path, notice: "Random Quest successfully created!"
    else
      flash.now[:alert] = "Failed to create random quest."
      render :home, status: :unprocessable_entity
    end
  end

  #  EDIT
  def edit; end

  # UPDATE
  def update
    if @task.update(task_params)
      redirect_to tasks_path, notice: "Quest updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # COMPLETE
  def complete
    # Mark task as completed
    @task.update(completed: true)

    # Ensure the creator is marked as participant
    @task.add_creator_as_participant

    # Award XP to all accepted participants
    @task.task_participants.where(status: "accepted").each do |tp|
      tp.user.add_xp(@task.xp.to_i)
    end

    redirect_to tasks_path, notice: "Quest completed! XP awarded."
  end

  # IGNORE / UNIGNORE
  def ignore
    @task.update(ignored: true)
    redirect_to tasks_path
  end

  def unignore
    @task.update(ignored: false)
    redirect_to tasks_path
  end

  # INVITATION SYSTEM

  # Invite a friend to a task
  def invite_friend
    friend = User.find(params[:friend_id])
    tp = @task.task_participants.find_or_initialize_by(user: friend)
    tp.status = "pending"

    if tp.save
      redirect_to tasks_path, notice: "#{friend.username} has been invited!"
    else
      redirect_to tasks_path, alert: "Could not invite #{friend.username}."
    end
  end

  # Accept a task invitation
  def accept_invitation
    tp = @task.task_participants.find_by(user: current_user)
    if tp&.update(status: "accepted")
      redirect_to tasks_path, notice: "Quest accepted!"
    else
      redirect_to tasks_path, alert: "You cannot accept this quest."
    end
  end

  # Decline a task invitation
  def decline_invitation
    tp = @task.task_participants.find_by(user: current_user)
    if tp&.update(status: "declined")
      redirect_to tasks_path, notice: "Quest declined!"
    else
      redirect_to tasks_path, alert: "You cannot decline this quest."
    end
  end

  private


  def task_params
    params.require(:task).permit(:name, :description, :daily, :xp, :duo, :partner_id, :date)
  end

  # BEFORE ACTION
  def set_task
    @task = Task.find(params[:id])
  end
end
