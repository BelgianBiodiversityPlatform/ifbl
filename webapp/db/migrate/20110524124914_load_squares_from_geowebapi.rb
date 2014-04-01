class LoadSquaresFromGeowebapi < ActiveRecord::Migration
  def self.up
    # similar to wget, needed to access web service
    require 'open-uri'
     
    #config:
    geowebapi_url = "http://localhost:4567/"
     
    # Add the column
    #add_column :areas, :the_geom, :polygon
    execute "SELECT AddGeometryColumn('areas', 'the_geom', 3857, 'POLYGON', 2)"
    
    # fill it :
    tot = Area.all
      
    tot.each do |a|
      unless a.ifbl_code.blank?
      processed_code = a.ifbl_code.delete('-')
      
      req_url = geowebapi_url + "ifbl_square?id=#{processed_code}&type=polygon&epsg=3857"
        wkt = open(req_url).read
        unless wkt == 'FALSE'
          req =  "UPDATE areas SET the_geom = ST_GeomFromText('#{wkt}', 3857) WHERE id = #{a.id}"
          puts "Will now execute : #{req}"
          execute req
        end
      end      
    end
  end

  def self.down
    remove_column :areas, :the_geom
  end
end
