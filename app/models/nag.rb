class Nag < ActiveRecord::Base
  validates_presence_of :contents
  validates_presence_of :user_id
  validates_presence_of :status

  belongs_to :user, inverse_of: :nags

  def declare_done
    update_attributes(status: "done")
  end

  def display_status
    user.status == "stopped" ? "stopped" : status
  end

  def self.populate_sidekiq
    @nag_to_be_pinged = self.first_nag_to_be_pinged
    NagWorker.perform_at(@nag_to_be_pinged.next_ping_time, @nag_to_be_pinged.id)
  end

  def self.first_nag_to_be_pinged
    self.all.order(:next_ping_time).last
  end
  
  def generate_next_ping_time
    update_attribute(:next_ping_time, next_ping_time + rand(5).hours + rand(61).minutes)
  end

  def self.test_worker_perform
    TestWorker.perform_async(1)
  end
end
