class AddObservationCounters < ActiveRecord::Migration
  def self.up
    add_column :species, :num_observations, :integer
    
    Species.all.each do |s|
      s.num_observations = s.observations.count
      s.save! 
    end
    
  end

  def self.down
    remove_column :species, :num_observations
  end
end
