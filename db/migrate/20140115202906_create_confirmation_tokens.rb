class CreateConfirmationTokens < ActiveRecord::Migration
  def up
    add_column :users, :confirmation_code, :string
    add_column :users, :confirmation_code_time, :datetime
  end

  def down
    remove_column :users, :confirmation_code
    remove_column :users, :confirmation_code_time
  end
end
