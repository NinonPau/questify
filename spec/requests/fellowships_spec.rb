require "rails_helper"

RSpec.describe "Fellowships", type: :request do
  let(:sender)   { User.create!(email: "s@example.com", password: "password", username: "sender") }
  let(:receiver) { User.create!(email: "r@example.com", password: "password", username: "receiver") }
  let(:other)    { User.create!(email: "o@example.com", password: "password", username: "other") }

  describe "POST /fellowships" do
    it "creates a pending fellowship request when ally exists" do
      sign_in sender

      expect {
        post fellowships_path, params: { ally_username: receiver.username }
      }.to change(Fellowship, :count).by(1)

      fellowship = Fellowship.last
      expect(fellowship.user).to eq(sender)
      expect(fellowship.ally).to eq(receiver)
      expect(fellowship.status).to eq("pending")
    end

    it "does not create a fellowship when ally does not exist" do
      sign_in sender

      expect {
        post fellowships_path, params: { ally_username: "unknown_user" }
      }.not_to change(Fellowship, :count)
    end
  end

  describe "PATCH /fellowships/:id" do
    let!(:fellowship) { Fellowship.create!(user: sender, ally: receiver, status: "pending") }

    it "allows receiver to accept" do
      sign_in receiver

      patch fellowship_path(fellowship), params: { status: "accepted" }
      expect(fellowship.reload.status).to eq("accepted")
    end

    it "prevents sender from accepting/declining (receiver only rule)" do
      sign_in sender

      patch fellowship_path(fellowship), params: { status: "accepted" }
      expect(fellowship.reload.status).to eq("pending")
    end
  end

  describe "DELETE /fellowships/:id" do
    let!(:fellowship) { Fellowship.create!(user: sender, ally: receiver, status: "accepted") }

    it "allows a participant to delete" do
      sign_in sender

      expect {
        delete fellowship_path(fellowship)
      }.to change(Fellowship, :count).by(-1)
    end

    it "denies an unrelated user" do
      sign_in other

      expect {
        delete fellowship_path(fellowship)
      }.not_to change(Fellowship, :count)
    end
  end
end
