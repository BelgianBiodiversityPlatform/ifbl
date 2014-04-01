class Hdc < ActiveRecord::Migration
  def self.up
      add_column :areas, :has_direct_checklists, :boolean, :default => false

      Checklist.all.each do |c|
	puts "processing checklist #{c.id}"
        area = c.most_precise_area
        area.has_direct_checklists = 1
        area.save!
      end
  end

  def self.down
      remove_column :areas, :has_direct_checklists
  end
end
