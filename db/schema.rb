# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120321132513) do

# Could not dump table "areas" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "checklists", :force => true do |t|
    t.integer "source_id"
    t.integer "area1_id"
    t.integer "area2_id"
    t.integer "area3_id"
    t.integer "model_id"
    t.date    "begin_date"
    t.date    "end_date"
    t.string  "observers",  :limit => 512
  end

  create_table "counters", :force => true do |t|
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geometry_columns", :id => false, :force => true do |t|
    t.string  "f_table_catalog",   :limit => 256, :null => false
    t.string  "f_table_schema",    :limit => 256, :null => false
    t.string  "f_table_name",      :limit => 256, :null => false
    t.string  "f_geometry_column", :limit => 256, :null => false
    t.integer "coord_dimension",                  :null => false
    t.integer "srid",                             :null => false
    t.string  "type",              :limit => 30,  :null => false
  end

  create_table "ifbl_2009", :id => false, :force => true do |t|
    t.text "IFBL"
    t.text "NaamWetenschappelijk"
    t.text "NaamNederlands"
    t.text "BeginDatum"
    t.text "EindDatum"
    t.text "Bron"
    t.text "Toponiem"
    t.text "Achternaam"
    t.text "Voornaam"
  end

  create_table "ifbl_2010", :id => false, :force => true do |t|
    t.text "IFBL"
    t.text "NaamWetenschappelijk"
    t.text "NaamNederlands"
    t.text "BeginDatum"
    t.text "EindDatum"
    t.text "Bron"
    t.text "Toponiem"
    t.text "Achternaam"
    t.text "Voornaam"
  end

  create_table "ifbl_input", :id => false, :force => true do |t|
    t.text "IFBL"
    t.text "NaamWetenschappelijk"
    t.text "NaamNederlands"
    t.text "BeginDatum"
    t.text "EindDatum"
    t.text "Bron"
    t.text "Toponiem"
    t.text "Achternaam"
    t.text "Voornaam"
  end

  create_table "ifbl_squares", :id => false, :force => true do |t|
    t.string "code", :limit => 8, :null => false
    t.float  "lat"
    t.float  "long"
  end

  create_table "inbo_dwca", :id => false, :force => true do |t|
    t.string  "guid",                          :limit => 32
    t.string  "country",                       :limit => 2
    t.text    "originalnameusage"
    t.text    "verbatimlocality"
    t.float   "decimallatitude"
    t.float   "decimallongitude"
    t.string  "basisofrecord",                 :limit => 32
    t.integer "catalognumber",                               :null => false
    t.text    "eventdate"
    t.string  "language",                      :limit => 8
    t.string  "verbatimtaxonrank",             :limit => 8
    t.string  "collectioncode",                :limit => 12
    t.string  "taxonrank",                     :limit => 32
    t.string  "scientificname",                :limit => 64
    t.string  "verbatimcoordinatesystem",      :limit => 8
    t.string  "institutioncode",               :limit => 4
    t.date    "modified"
    t.string  "geodeticdatum",                 :limit => 5
    t.string  "verbatimcoordinates",           :limit => 8
    t.text    "occurrencedetails"
    t.text    "recordedby"
    t.string  "nomenclaturalcode",             :limit => 4
    t.integer "coordinateuncertaintyinmeters"
    t.text    "legalrights"
  end

  create_table "models", :force => true do |t|
    t.integer "source_id"
    t.string  "name",      :limit => 64
  end

  create_table "observations", :force => true do |t|
    t.integer "source_id"
    t.integer "original_id"
    t.integer "checklist_id"
    t.integer "species_id"
  end

  add_index "observations", ["checklist_id"], :name => "observations_checklist_id_idx"

  create_table "observers", :id => false, :force => true do |t|
    t.integer "source_id"
    t.integer "checklist_id"
    t.integer "person_id"
  end

  create_table "people", :force => true do |t|
    t.integer "source_id"
    t.string  "family_name", :limit => 256
    t.string  "first_name",  :limit => 256
  end

  create_table "sources", :force => true do |t|
    t.string "name",            :limit => 256
    t.string "institutioncode", :limit => 8
    t.string "collectioncode",  :limit => 8
    t.date   "lastupdate"
  end

  create_table "spatial_ref_sys", :id => false, :force => true do |t|
    t.integer "srid",                      :null => false
    t.string  "auth_name", :limit => 256
    t.integer "auth_srid"
    t.string  "srtext",    :limit => 2048
    t.string  "proj4text", :limit => 2048
  end

  create_table "species", :force => true do |t|
    t.integer "source_id"
    t.string  "scientific_name",  :limit => 256
    t.string  "fr_name",          :limit => 256
    t.string  "en_name",          :limit => 256
    t.string  "nl_name",          :limit => 256
    t.integer "num_observations"
  end

  add_index "species", ["scientific_name"], :name => "species_scientific_name_key", :unique => true

end
