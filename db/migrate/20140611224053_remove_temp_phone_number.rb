class RemoveTempPhoneNumber < ActiveRecord::Migration
  def up
    remove_column :users, :phone_number_temp
  end

  def down
    add_column :users, :phone_number_temp, :string
  end
end
