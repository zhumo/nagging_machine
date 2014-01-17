class AddPhoneNumberTempToUser < ActiveRecord::Migration
  def up
    add_column :users, :phone_number_temp, :string
  end

  def down
    remove_column :users, :phone_number_temp
  end
end
