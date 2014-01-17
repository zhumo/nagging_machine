class AddNextPingTimeToNags < ActiveRecord::Migration
  def up
    add_column :nags, :next_ping_time, :datetime
  end

  def down
    remove_column :nags, :next_ping_time
  end
end
