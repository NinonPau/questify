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

#  when user model gets implemented, add the following to it:

  # def add_xp(amount)
  #   current_total = total_xp || 0
  #   bonus = user_mood&.xp_bonus || 1.0
  #   update(total_xp: current_total + amount.to_f * bonus)
  # end

  # def current_level
  #   case total_xp
  #     when 0..250
  #     1
  #     when 251..800
  #     2
  #     when 801..2000
  #       3
  #     when 2001..4600
  #       4
  #     when 4601..10000
  #       5
  #     when 10001..22000
  #       6
  #     when 22001..48000
  #       7
  #     when 48001..104000
  #       8
  #     when 104001..224000
  #       9
  #     when 224001..480000
  #       10
  #   end
  # end

#  def xp_progress_percent
#   levels = {
#     1 => 0..250,
#     2 => 251..800,
#     3 => 801..2000,
#     4 => 2001..4600,
#     5 => 4601..10000,
#     6 => 10001..22000,
#     7 => 22001..48000,
#     8 => 48001..104000,
#     9 => 104001..224000,
#     10 => 224001..480000
#   }
#   current_level_range = levels[current_level]
#   return { percent: 100, remaining: 0 } if current_level_range.nil?
#   min = current_level_range.begin
#   max = current_level_range.end
#   xp_into_level = total_xp - min
#   xp_required = max - min
#   percent = (xp_into_level.to_f / xp_required) * 100
#    {
#     percent: percent.round(2),
#     remaining: (max - total_xp).round(0)
#    }
#  end