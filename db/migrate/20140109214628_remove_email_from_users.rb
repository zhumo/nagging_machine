class RemoveEmailFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :email
  end
  
  def down
    add_column :users, :email, :string, null: false, default: ""
    add_index :users, :email, unique: true
  end
end
