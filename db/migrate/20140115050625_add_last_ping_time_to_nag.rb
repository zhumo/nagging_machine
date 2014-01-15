class AddLastPingTimeToNag < ActiveRecord::Migration
  def up
    add_column :nags, :last_ping_time, :datetime, default: Time.at(0)
  end

  def down
    remove_column :nags, :last_ping_time
  end
end
