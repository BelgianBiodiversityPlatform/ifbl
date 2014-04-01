class CreateCounters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.string :name
      t.integer :value
      t.timestamps
    end
  end

  def self.down
    drop_table :counters
  end
end
