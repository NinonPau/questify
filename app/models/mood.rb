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
    Bad: "Bad",
  }, _suffix: true# avoid naming conflict, clean, safe

  def set_xp_bonus
    case @mood.mood_type
    when "Amazing" then 1.25
    when "Good" then 1.50
    when "Ok'ish" then 2.00
    when "Bad" then 3.00
    end
  end
end
