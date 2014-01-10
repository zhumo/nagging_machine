class AddUserIdToNags < ActiveRecord::Migration
  def up
    add_column :nags, :user_id, :integer, null: false
  end

  def down
    remove_column :nags, :user_id
  end
end
