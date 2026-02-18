# This file tests the policy (Pundit) for quests
require "rails_helper"

RSpec.describe QuestPolicy do
  subject(:policy) { described_class }

  # Tests have to be isolated, so we can't rely on seeds.
  # We create the users, fellowship, quest and quest_participant needed for the tests.

  let(:owner)   { User.create!(email: "owner@example.com", password: "password", username: "owner") }
  let(:ally)    { User.create!(email: "ally@example.com", password: "password", username: "ally") }
  let(:stranger){ User.create!(email: "stranger@example.com", password: "password", username: "stranger") }

  # The quest is owned by the owner
  let(:quest) { Quest.create!(user: owner, name: "Quest", description: "Test", xp: 10, date: Date.today) }

  # Fellowship must be accepted to grant visibility through invitations
  let(:accepted_fellowship) { Fellowship.create!(user: owner, ally: ally, status: "accepted") }
  

  # Link the accepted fellowship to the quest (this represents an invitation/help request)
  let!(:quest_participant) { QuestParticipant.create!(quest: quest, fellowship: accepted_fellowship, status: "pending") }
  l

  describe "Scope" do
    it "includes quests owned by the user" do
      resolved = QuestPolicy::Scope.new(owner, Quest).resolve
      # create a variable(resolved) - create a new instance in the class Scope define by QuestPolicy- the :: mean go find Scope inside QuestPolicy
      # .new(owner, Quest) - initialize the Scope with the current user (owner) and the model (Quest)
      # .resolve - call the resolve method to get the quests visible to the owner
      # then we check that the resolved variable include the quest owned by the owner
      expect(resolved).to include(quest)
    end

    it "includes quests where the user is invited via an accepted fellowship AND a help request exists" do
      resolved = QuestPolicy::Scope.new(ally, Quest).resolve
      expect(resolved).to include(quest)
    end

    it "excludes quests for unrelated users" do
      resolved = QuestPolicy::Scope.new(stranger, Quest).resolve
      expect(resolved).not_to include(quest)
    end

    it "does not grant access through pending fellowships" do
      pending_user = User.create!(email: "pending@example.com", password: "password", username: "pending")

      pending_fellowship = Fellowship.create!(user: owner, ally: pending_user, status: "pending")
      QuestParticipant.create!(quest: quest, fellowship: pending_fellowship, status: "pending")

      resolved = QuestPolicy::Scope.new(pending_user, Quest).resolve
      expect(resolved).not_to include(quest)
    end
  end

  describe "#show?" do
    it "allows the owner" do
      expect(policy.new(owner, quest)).to be_show
    end

    it "allows an invited ally if the fellowship is accepted" do
      expect(policy.new(ally, quest)).to be_show
    end

    it "denies unrelated users" do
      expect(policy.new(stranger, quest)).not_to be_show
    end
  end

  describe "#create?" do
    it "allows any logged-in user" do
      new_quest = Quest.new(user: stranger, name: "New quest", xp: 0)
      expect(policy.new(stranger, new_quest)).to be_create
    end
  end

  describe "#update?" do
    it "allows the owner" do
      expect(policy.new(owner, quest)).to be_update
    end

    it "denies invited allies" do
      expect(policy.new(ally, quest)).not_to be_update
    end

    it "denies unrelated users" do
      expect(policy.new(stranger, quest)).not_to be_update
    end
  end

  describe "#destroy?" do
    it "allows the owner" do
      expect(policy.new(owner, quest)).to be_destroy
    end

    it "denies invited allies" do
      expect(policy.new(ally, quest)).not_to be_destroy
    end

    it "denies unrelated users" do
      expect(policy.new(stranger, quest)).not_to be_destroy
    end
    

  end
end
