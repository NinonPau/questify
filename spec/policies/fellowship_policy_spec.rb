#this file test the policy (pundit) for fellowship 
require "rails_helper"

RSpec.describe FellowshipPolicy do
  subject(:policy) { described_class }
# test have to be isolated so we can't use seeds.
# we create the users and fellowship needed for the tests
  let(:sender)   { User.create!(email: "s@example.com", password: "password", username: "sender") }
  let(:receiver) { User.create!(email: "r@example.com", password: "password", username: "receiver") }
  let(:other)    { User.create!(email: "o@example.com", password: "password", username: "other") }
# fellowship between sender and receiver
  let(:fellowship) { Fellowship.create!(user: sender, ally: receiver, status: "pending") }

  describe "Scope" do
    it "returns only fellowships where the user is involved" do
      # another fellowship unrelated to sender
      Fellowship.create!(user: receiver, ally: other, status: "pending")

      resolved = FellowshipPolicy::Scope.new(sender, Fellowship).resolve

      expect(resolved).to include(fellowship)
      expect(resolved.all? { |f| f.user_id == sender.id || f.user_ally_id == sender.id }).to be(true)
    end
  end

  describe "#create?" do
    it "allows any logged-in user" do
      expect(policy.new(sender, Fellowship.new(user: sender, ally: receiver))).to be_create
    end
  end

  describe "#update?" do
    it "allows sender" do
      expect(policy.new(sender, fellowship)).to be_update
    end

    it "allows receiver" do
      expect(policy.new(receiver, fellowship)).to be_update
    end

    it "denies unrelated user" do
      expect(policy.new(other, fellowship)).not_to be_update
    end
  end

  describe "#destroy?" do
    it "allows participants" do
      expect(policy.new(sender, fellowship)).to be_destroy
      expect(policy.new(receiver, fellowship)).to be_destroy
    end

    it "denies unrelated user" do
      expect(policy.new(other, fellowship)).not_to be_destroy
    end
  end
end
