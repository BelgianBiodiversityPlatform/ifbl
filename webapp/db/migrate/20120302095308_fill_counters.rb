class FillCounters < ActiveRecord::Migration
  def self.up
    c = Counter.new(:name => 'checklists', :value => Checklist.count)
    c.save!
    
    c = Counter.new(:name => 'observations', :value => Observation.count)
    c.save!
    
    c = Counter.new(:name => 'species', :value => Species.count)
    c.save!
    
    c = Counter.new(:name => 'observers', :value => Person.count)
    c.save!
  end

  def self.down
    Counter.delete_all
  end
end
