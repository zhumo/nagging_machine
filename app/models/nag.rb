class Nag < ActiveRecord::Base
  validates_presence_of :contents

  belongs_to :user, inverse_of: :nags

  def declare_done
    update_attributes(status: "done")
  end

  def display_status
    user.status == "stopped" ? "stopped" : status
  end
end
