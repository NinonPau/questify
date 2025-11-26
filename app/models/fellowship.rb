class Fellowship < ApplicationRecord
  belongs_to :user
  belongs_to :user_ally
end
