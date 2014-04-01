class HdcView < ActiveRecord::Migration
  def self.up
    execute "CREATE OR REPLACE VIEW areas_with_direct_checklists AS
      SELECT *
      FROM nbgb_ifbl.areas
      WHERE areas.has_direct_checklists = true
      ORDER BY areas.uncertainty;"

    execute "CREATE OR REPLACE VIEW areas_4_derived_from_1 AS
      SELECT * FROM areas WHERE coordinatesystem LIKE 'IFBL 4km' AND ifbl_code IN
      (SELECT DISTINCT SUBSTRING(ifbl_code FROM 1 FOR 5) FROM areas WHERE coordinatesystem LIKE 'IFBL 1km')"
  end

  def self.down
    execute "DROP VIEW areas_with_direct_checklists;"
    execute "DROP VIEW areas_4_derived_from_1;"
  end
end
