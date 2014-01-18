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

  def generate_next_ping_time
    update_attribute(:next_ping_time, Time.now + rand(5).hours + rand(61).minutes)
  end

  def self.populate_sidekiq
    @nag = self.first_nag_to_be_pinged

    if @nag.next_ping_time.hour >= 4 && @nag.next_ping_time.hour < 13
      Sidekiq::ScheduledSet.new.clear
      @nag.generate_next_ping_time
      Nag.populate_sidekiq
    else
      NagWorker.perform_at(@nag.next_ping_time, @nag.id)
    end
  end

  def self.first_nag_to_be_pinged
    self.where(status: "active").order(:next_ping_time).first
  end
  
end
