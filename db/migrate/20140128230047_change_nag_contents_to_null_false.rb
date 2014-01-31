class ChangeNagContentsToNullFalse < ActiveRecord::Migration
  def up
    change_column :nags, :contents, :string, null: false
  end

  def down
    change_column :nags, :contents, :string
  end
end
