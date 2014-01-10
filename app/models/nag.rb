class Nag < ActiveRecord::Base
  validates_presence_of :contents

  belongs_to :user, inverse_of: :nags
end
