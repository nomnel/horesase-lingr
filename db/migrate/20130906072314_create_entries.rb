class CreateEntries < ActiveRecord::Migration
  def up
    create_table :entries do |t|
      t.string :url, null: false

      t.timestamps
    end
  end

  def down
    drop_table :entries
  end
end
