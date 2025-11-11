# spec/controllers/tasks_controller_spec.rb
require 'rails_helper'
require 'faker'

RSpec.describe TasksController, type: :controller do
  let(:user) { User.create!(email: Faker::Internet.unique.email, password: "password", username: Faker::Internet.username) }
  let(:friend) { User.create!(email: Faker::Internet.unique.email, password: "password", username: Faker::Internet.username) }

  before { sign_in user }

  describe "GET #index" do
    it "assigns today's tasks and participating tasks" do
      task_today = Task.create!(name: "Today Task", description: "Desc", xp: 10, date: Date.today, user: user)
      participant_task = Task.create!(name: "Participant Task", description: "Desc", xp: 10, date: Date.today, user: friend)
      TaskParticipant.create!(task: participant_task, user: user, status: "accepted")

      get :index

      expect(response).to have_http_status(:success)
      expect(assigns(:tasks)).to include(task_today)
      expect(assigns(:participating_tasks)).to include(participant_task)
    end
  end

  describe "GET #new" do
    it "assigns a new task" do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe "POST #create" do
    let(:valid_params) { { name: "Test Task", description: "Description", xp: 10 } }

    it "creates a new task and redirects" do
      expect {
        post :create, params: { task: valid_params }
      }.to change(Task, :count).by(1)

      expect(response).to redirect_to(tasks_path)
    end

    it "renders :new if invalid" do
      post :create, params: { task: { name: "" } }
      expect(response).to render_template(:new)
      expect(response.status).to eq(422)
    end
  end

  describe "PATCH #update" do
    let!(:task) { Task.create!(name: "Old Task", description: "Old Desc", xp: 5, date: Date.today, user: user) }

    it "updates the task" do
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

  describe "PATCH #complete" do
    let!(:task) { Task.create!(name: "Task to complete", description: "Complete me", xp: xp_value, date: Date.today, user: user) }

    context "for a normal task (from new/create)" do
      let(:xp_value) { 10 }

      it "marks the task as completed and adds XP to participants" do
        patch :complete, params: { id: task.id }
        task.reload
        expect(task.completed).to be_truthy
        expect(user.reload.total_xp).to eq(xp_value)
        expect(response).to redirect_to(tasks_path)
      end
    end

    context "for a random task (from random action)" do
      let(:xp_value) { 20 }  # correspond à ce que random met

      it "marks the random task as completed and adds XP" do
        patch :complete, params: { id: task.id }
        task.reload
        expect(task.completed).to be_truthy
        expect(user.reload.total_xp).to eq(xp_value)
        expect(response).to redirect_to(tasks_path)
      end
    end
  end


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

  describe "POST #invite_friend" do
    let!(:task) { Task.create!(name: "Task", description: "Desc", xp: 10, date: Date.today, user: user) }

    it "invites a friend" do
      post :invite_friend, params: { id: task.id, friend_id: friend.id }
      expect(TaskParticipant.exists?(task: task, user: friend)).to be true
      expect(response).to redirect_to(tasks_path)
    end
  end

  describe "PATCH #accept_invitation and #decline_invitation" do
    let!(:task) { Task.create!(name: "Task", description: "Desc", xp: 10, date: Date.today, user: user) }
    let!(:tp) { TaskParticipant.create!(task: task, user: friend, status: "pending") }

    before { sign_in friend }

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
