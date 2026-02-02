class Mood < ApplicationRecord

  # ASSOCIATIONS

  belongs_to :user

  # VALIDATIONS
  validates :mood_type, presence: true
  # OPTIONAL ENUM (recommended) created automatic helpers, avoi typo, queries much easier,centrelize allowed valued in one place, make form more easy,

  # Example moods — adjust as you want
  enum mood_type: {
    amazing: "Amazing",
    good: "Good",
    OKish: "Ok'ish",
    bad: "Bad",
    calm: "Calm"
  }, _suffix: true# avoid naming conflict, clean, safe
end