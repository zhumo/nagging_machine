class CreateNags < ActiveRecord::Migration
  def change
    create_table :nags do |t|
      t.string :contents, null: false
      t.string :status, null: false, default: "active"
      t.integer :ping_count, null: false, default: 0
    end
  end
end
