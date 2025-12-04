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

  # Hearths Created by this user
  has_many :owned_hearths,
           class_name: "Hearth",
           foreign_key: "creator_id",
           dependent: :destroy

  # Join table when participating in a hearth (invited or own)
  has_many :hearth_participants, dependent: :destroy

  # Hearths the user participates in (invited or added automatically if owner)
  has_many :participating_hearths,
           through: :hearth_participants,
           source: :hearth

  # chat participation
  has_many :hearth_participants, dependent: :destroy

  # messages
  has_many :messages, dependent: :destroy


end
