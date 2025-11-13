# spec/controllers/tasks_controller_spec.rb
require 'rails_helper'
require 'faker'

# This file tests the behavior of the TasksController
# It ensures all actions (index, create, update, complete, etc.) work correctly.
RSpec.describe TasksController, type: :controller do

  # Create two fake users using Faker (one main user and one friend)
  let(:user) { User.create!(email: Faker::Internet.unique.email, password: "password", username: Faker::Internet.username) }
  let(:friend) { User.create!(email: Faker::Internet.unique.email, password: "password", username: Faker::Internet.username) }

  # Sign in the main user before each test (Devise helper)
  before { sign_in user }

  
  # INDEX ACTION

  describe "GET #index" do
    it "assigns today's tasks and participating tasks" do
      # Create a task belonging to the current user
      task_today = Task.create!(name: "Today Task", description: "Desc", xp: 10, date: Date.today, user: user)

      # Create a task from another user and make the current user a participant
      participant_task = Task.create!(name: "Participant Task", description: "Desc", xp: 10, date: Date.today, user: friend)
      TaskParticipant.create!(task: participant_task, user: user, status: "accepted")

      # Send GET request to the index action
      get :index

      # Expect the response to be successful (HTTP 200)
      expect(response).to have_http_status(:success)

      # Expect @tasks to include only today's tasks
      expect(assigns(:tasks)).to include(task_today)

      # Expect @participating_tasks to include the ones where the user is a participant
      expect(assigns(:participating_tasks)).to include(participant_task)
    end
  end


  # NEW ACTION

  describe "GET #new" do
    it "assigns a new task" do
      get :new
      expect(response).to have_http_status(:success)
      # @task should be a new unsaved Task object
      expect(assigns(:task)).to be_a_new(Task)
    end
  end


  # CREATE ACTION

  describe "POST #create" do
    # Valid attributes for a task
    let(:valid_params) { { name: "Test Task", description: "Description", xp: 10 } }

    it "creates a new task and redirects" do
      # Expect Task count to increase by 1 after POST request
      expect {
        post :create, params: { task: valid_params }
      }.to change(Task, :count).by(1)

      # Expect redirect to the tasks index page
      expect(response).to redirect_to(tasks_path)
    end

    it "renders :new if invalid" do
      # Missing name should make validation fail
      post :create, params: { task: { name: "" } }
      expect(response).to render_template(:new)
      expect(response.status).to eq(422) # Unprocessable Entity
    end
  end


  # UPDATE ACTION

  describe "PATCH #update" do
    # Create an existing task to update
    let!(:task) { Task.create!(name: "Old Task", description: "Old Desc", xp: 5, date: Date.today, user: user) }

    it "updates the task" do
      # Send PATCH request with new data
      patch :update, params: { id: task.id, task: { name: "Updated" } }
      task.reload
      expect(task.name).to eq("Updated")
      expect(response).to redirect_to(tasks_path)
    end

    it "renders edit if invalid" do
      patch :update, params: { id: task.id, task: { name: "" } }
      expect(response).to render_template(:edit)
      expect(response.status).to eq(422)
    end
  end


  # COMPLETE ACTION

  describe "PATCH #complete" do
    # Task with dynamic XP value (depending on context)
    let!(:task) { Task.create!(name: "Task to complete", description: "Complete me", xp: xp_value, date: Date.today, user: user) }

    context "for a normal task (from new/create)" do
      let(:xp_value) { 10 }

      it "marks the task as completed and adds XP to participants" do
        patch :complete, params: { id: task.id }
        task.reload
        expect(task.completed).to be_truthy
        # Check that the user’s XP increased by the task XP
        expect(user.reload.total_xp).to eq(xp_value)
        expect(response).to redirect_to(tasks_path)
      end
    end

    context "for a random task (from random action)" do
      let(:xp_value) { 20 }  # Random tasks have 20 XP by default

      it "marks the random task as completed and adds XP" do
        patch :complete, params: { id: task.id }
        task.reload
        expect(task.completed).to be_truthy
        expect(user.reload.total_xp).to eq(xp_value)
        expect(response).to redirect_to(tasks_path)
      end
    end
  end


  # IGNORE / UNIGNORE ACTIONS

  describe "PATCH #ignore and #unignore" do
    let!(:task) { Task.create!(name: "Task", description: "Desc", xp: 10, date: Date.today, user: user) }

    it "ignores a task" do
      patch :ignore, params: { id: task.id }
      task.reload
      expect(task.ignored).to be true
      expect(response).to redirect_to(tasks_path)
    end

    it "unignores a task" do
      task.update(ignored: true)
      patch :unignore, params: { id: task.id }
      task.reload
      expect(task.ignored).to be false
      expect(response).to redirect_to(tasks_path)
    end
  end


  # INVITE FRIEND ACTION

  describe "POST #invite_friend" do
    let!(:task) { Task.create!(name: "Task", description: "Desc", xp: 10, date: Date.today, user: user) }

    it "invites a friend" do
      # Send POST request to invite a friend to the task
      post :invite_friend, params: { id: task.id, friend_id: friend.id }

      # A TaskParticipant record should now exist
      expect(TaskParticipant.exists?(task: task, user: friend)).to be true

      # Redirects back to tasks list
      expect(response).to redirect_to(tasks_path)
    end
  end


  # ACCEPT / DECLINE INVITATION ACTIONS

  describe "PATCH #accept_invitation and #decline_invitation" do
    let!(:task) { Task.create!(name: "Task", description: "Desc", xp: 10, date: Date.today, user: user) }
    let!(:tp) { TaskParticipant.create!(task: task, user: friend, status: "pending") }

    before { sign_in friend } # Now simulate that the friend logs in

    it "accepts invitation" do
      patch :accept_invitation, params: { id: task.id }
      tp.reload
      expect(tp.status).to eq("accepted")
      expect(response).to redirect_to(tasks_path)
    end

    it "declines invitation" do
      patch :decline_invitation, params: { id: task.id }
      tp.reload
      expect(tp.status).to eq("declined")
      expect(response).to redirect_to(tasks_path)
    end
  end
end
