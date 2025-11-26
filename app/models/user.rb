class User < ApplicationRecord
  # DEVISE
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ASSOCIATIONS
  # quests owned by this user
  has_many :quests, dependent: :destroy

  # friendships where I am the initiator
  has_many :fellowships, dependent: :destroy

  # friendships where I am the ally
  has_many :reverse_fellowships,
           class_name: "Fellowship",
           foreign_key: "user_ally_id",
           dependent: :destroy

  # hearths
  has_many :hearths, dependent: :destroy

  # chat participation
  has_many :hearth_participants, dependent: :destroy

  # messages
  has_many :messages, dependent: :destroy

  
end
