class AddDefaultToNextPingTime < ActiveRecord::Migration
  def up
    change_column :nags, :next_ping_time, :datetime, default: Time.at(0)
  end

  def down
    change_column :nags, :next_ping_time, :datetime, default: nil
  end
end
