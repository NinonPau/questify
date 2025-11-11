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
end
