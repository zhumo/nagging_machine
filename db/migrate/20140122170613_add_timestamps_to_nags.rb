class AddTimestampsToNags < ActiveRecord::Migration
  def change
    add_column(:nags, :created_at, :datetime)
    add_column(:nags, :updated_at, :datetime)
  end
end
