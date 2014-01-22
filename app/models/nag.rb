class Nag < ActiveRecord::Base
  validates_presence_of :contents
  validates_presence_of :user_id
  validates_presence_of :status

  belongs_to :user, inverse_of: :nags

  def declare_done
    update_attributes(status: "done")
    Nag.populate_sidekiq
  end

  def display_status
    user.status == "stopped" ? "stopped" : status
  end

  def generate_next_ping_time
    until :next_ping_time > Time.now
      update_attribute(:next_ping_time, next_ping_time + rand(4..6).hours + rand(60).minutes)
    end
  end

  def self.populate_sidekiq
    @nag = self.first_nag_to_be_pinged

    if @nag
      if @nag.next_ping_time.hour >= 4 && @nag.next_ping_time.hour < 13
        @nag.generate_next_ping_time
        Nag.populate_sidekiq
      else
        Sidekiq::ScheduledSet.new.clear
        NagWorker.perform_at(@nag.next_ping_time, @nag.id)
      end
    end
  end

  def self.first_nag_to_be_pinged
    Nag.where(status: "active").select{|nag| nag.user.status == "active" }.sort_by{|nag| nag.next_ping_time }.first
  end
  
end
