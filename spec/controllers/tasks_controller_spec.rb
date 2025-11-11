# spec/controllers/tasks_controller_spec.rb
require 'rails_helper'
require 'faker'

RSpec.describe TasksController, type: :controller do
  let(:user) { User.create!(email: Faker::Internet.unique.email, password: "password", username: Faker::Internet.username) }
  let(:friend) { User.create!(email: Faker::Internet.unique.email, password: "password", username: Faker::Internet.username) }

  before do
    sign_in user  # Devise helper to simulate a signed-in user
  end

  describe "GET #index" do
    it "shows today's tasks and pending/accepted invitations, excluding declined ones" do
      # Today's task created by the user
      task_today = Task.create!(name: "Today's Task", description: "Description", xp: 10, date: Date.today, user: user)

      # Tasks with invitations
      accepted_task = Task.create!(name: "Accepted Task", description: "Desc", xp: 10, date: Date.today, user: friend)
      pending_task = Task.create!(name: "Pending Task", description: "Desc", xp: 10, date: Date.today, user: friend)
      declined_task = Task.create!(name: "Declined Task", description: "Desc", xp: 10, date: Date.today, user: friend)

      # Simulate invitations (TaskParticipant)
      TaskParticipant.create!(task: accepted_task, user: user, status: "accepted")
      TaskParticipant.create!(task: pending_task, user: user, status: "pending")
      TaskParticipant.create!(task: declined_task, user: user, status: "declined")

      get :index

      expect(response).to have_http_status(:success)

      # Tasks created by the user today
      expect(assigns(:tasks)).to include(task_today)

      # Tasks where the user is a participant (accepted/pending)
      expect(assigns(:participating_tasks)).to include(accepted_task, pending_task)
      # Should not include declined tasks
      expect(assigns(:participating_tasks)).not_to include(declined_task)
    end

  end
  describe "GET #new" do
    context "when user is signed in" do
      before { sign_in user }

      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end

      it "assigns a new task to @task" do
        get :new
        expect(assigns(:task)).to be_a_new(Task)
      end
      it "assigns a new task with default attributes" do
        get :new
        task = assigns(:task)
        expect(task).to be_a_new(Task)               # new unsaved task
        expect(task.user).to eq(user)                # associated with current_user
        expect(task.name).to be_nil                  # name is empty by default
        expect(task.date).to eq(Date.today)          # date defaults to today
        expect(task.daily).to be_nil                 # daily defaults to nil
        expect(task.xp).to be_nil                    # xp defaults to nil
      end
    end

  end
  describe "POST #create" do
    context "with valid attributes" do
      let(:valid_task_params) do
        {
          name: Faker::Lorem.sentence(word_count: 3),
          description: Faker::Lorem.paragraph,
          xp: Faker::Number.between(from: 5, to: 100)
        }
      end

      it "creates a new task with default date today" do
        expect {
          post :create, params: { task: valid_task_params }
        }.to change(Task, :count).by(1)

        task = Task.last
        expect(task.name).to eq(valid_task_params[:name])
        expect(task.description).to eq(valid_task_params[:description])
        expect(task.xp).to eq(valid_task_params[:xp])
        expect(task.date).to eq(Date.today)
        expect(task.user).to eq(user)
      end

      it "redirects to tasks_path with notice" do
        post :create, params: { task: valid_task_params }
        expect(response).to redirect_to(tasks_path)
        expect(flash[:notice]).to eq("Task successfully created!")
      end
    end

    context "with invalid attributes" do
      let(:invalid_task_params) do
        {
          name: "", # Invalid: name is required
          description: Faker::Lorem.sentence
        }
      end

      it "does not create a task" do
        expect {
          post :create, params: { task: invalid_task_params }
        }.not_to change(Task, :count)
      end

      it "renders the new template with unprocessable_entity" do
        post :create, params: { task: invalid_task_params }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with a random future date" do
      let(:valid_task_params) do
        {
          name: Faker::Lorem.sentence(word_count: 3),
          description: Faker::Lorem.paragraph,
          xp: Faker::Number.between(from: 5, to: 100),
          date: Faker::Date.forward(days: 365) # random date within next year
        }
      end

      it "creates a new task with a random future date" do
        random_date = valid_task_params[:date]

        expect {
          post :create, params: { task: valid_task_params }
        }.to change(Task, :count).by(1)

        task = Task.last
        expect(task.name).to eq(valid_task_params[:name])
        expect(task.description).to eq(valid_task_params[:description])
        expect(task.xp).to eq(valid_task_params[:xp])
        expect(task.date).to eq(random_date)
        expect(task.user).to eq(user)
      end
    end
  end
end
