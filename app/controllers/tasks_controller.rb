require "json"
require "open-uri"

class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy complete ignore unignore invite_friend accept_invitation decline_invitation]
  after_action :verify_authorized, except: %i[index random]
  after_action :verify_policy_scoped, only: :index

  # READ
  def index
    # Today's tasks created by the user or daily task or programme task
    @tasks = policy_scope(Task).today

    # Tasks where user participate(accepted or pending)
    @participating_tasks = current_user.task_participants
                                       .where(status: %w[pending accepted])
                                       .includes(:task)
                                       .map(&:task)
  end

  def show
    authorize @task
  end

  #  CREATE
  def new
    @task = current_user.tasks.new
    authorize @task
  end

  def create
    # Use the date from params if provided, otherwise default to today
    task_date = if task_params[:date].present?
                  Date.parse(task_params[:date]) rescue Date.today
                else
                  Date.today
                end

    @task = current_user.tasks.new(task_params.merge(date: task_date))
    authorize @task

    if @task.save
      redirect_to tasks_path, notice: "Task successfully created!"
    else
      flash.now[:alert] = "Failed to create task."
      render :new, status: :unprocessable_entity
    end
  end



  # Generate a random task from boredAPI API
  def random
    activity = JSON.parse(URI.open("https://bored.api.lewagon.com/api/activity").read)
    @task = current_user.tasks.new(
      name: activity["activity"],
      description: "Type: #{activity["type"]} - Participants: #{activity["participants"]}" \
                   "#{activity["link"].present? ? " - Link: #{activity["link"]}" : ""}",
      xp: 20,
      date: Date.today
    )
    authorize @task

    if @task.save
      redirect_to tasks_path, notice: "Random task created!"
    else
      flash.now[:alert] = "Failed to create random task."
      render :home, status: :unprocessable_entity
    end
  end

  # UPDATE
  def edit
    authorize @task
  end

  def update
    authorize @task
    if @task.update(task_params)
      redirect_to tasks_path, notice: "Task successfully updated!"
    else
      flash.now[:alert] = "Failed to update task."
      render :edit, status: :unprocessable_entity
    end
  end

  #  DELETE
  def destroy
    authorize @task
    @task.destroy
    redirect_to tasks_path, notice: "Task deleted."
  end

  # CUSTOM ACTIONS
  def complete
    authorize @task
    @task.complete!
    redirect_to tasks_path, notice: "Task completed!"
  end

  def ignore
    authorize @task
    @task.update(ignored: true)
    redirect_to tasks_path, notice: "Task ignored."
  end

  def unignore
    authorize @task
    @task.update(ignored: false)
    redirect_to tasks_path, notice: "Task unignored."
  end

  def invite_friend
    authorize @task
    friend = User.find(params[:friend_id])

    if @task.invite(friend)
      redirect_to tasks_path, notice: "#{friend.username} has been invited!"
    else
      redirect_to tasks_path, alert: "Could not invite #{friend.username}."
    end
  end

  def accept_invitation
    authorize @task
    if @task.accept_invitation(current_user)
      redirect_to tasks_path, notice: "Invitation accepted!"
    else
      redirect_to tasks_path, alert: "You can't accept this invitation."
    end
  end

  def decline_invitation
    authorize @task
    if @task.decline_invitation(current_user)
      redirect_to tasks_path, notice: "Invitation declined."
    else
      redirect_to tasks_path, alert: "You can't decline this invitation."
    end
  end

  private

  # Strong Params
  def task_params
    params.require(:task).permit(:name, :description, :daily, :xp, :duo, :partner_id, :date)
  end

  # Find the task by ID
  def set_task
    @task = Task.find(params[:id])
  end
end
