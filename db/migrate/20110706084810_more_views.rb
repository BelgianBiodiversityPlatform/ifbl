class MoreViews < ActiveRecord::Migration
  def self.up
    execute "CREATE OR REPLACE VIEW squares_per_species AS (
SELECT areas.the_geom, areas.ifbl_code, COUNT(*) AS nb_observations, observations.species_id
FROM areas, checklists, observations
WHERE checklists.area3_id = areas.id AND observations.checklist_id = checklists.id
GROUP BY areas.ifbl_code, areas.the_geom, observations.species_id
)"
  end

  def self.down
    execute "DROP VIEW squares_per_species"
  end
end
