class Submission < ActiveRecord::Base
  belongs_to :user
  belongs_to :moderator, class_name: "User", foreign_key: 'moderator_id'
end
