class AddStatusToUsers < ActiveRecord::Migration
  def up
    add_column :users, :status, :string, null: false, default: "awaiting confirmation"
  end

  def down
    remove_column :users, :status
  end
end
