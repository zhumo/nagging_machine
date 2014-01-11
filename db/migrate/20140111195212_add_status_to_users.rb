class AddStatusToUsers < ActiveRecord::Migration
  def up
    add_column :users, :status, :string, null: false, default: "active"
  end

  def down
    remove_column :users, :status
  end
end
