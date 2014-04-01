class Indexadd < ActiveRecord::Migration
  def self.up
    execute "CREATE INDEX observations_checklist_id_idx ON observations USING btree (checklist_id);"
  end

  def self.down
    execute "DROP INDEX observations_checklist_id_idx;"
  end
end
