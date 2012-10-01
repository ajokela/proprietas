# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20121001012904) do

  create_table "counties", :force => true do |t|
    t.string   "name",        :limit => 128
    t.integer  "fipscode"
    t.string   "county_seat", :limit => 128
    t.integer  "established"
    t.text     "origin"
    t.text     "etymology"
    t.integer  "area_miles",  :limit => 8
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "foreclosures", :force => true do |t|
    t.string   "parid",         :limit => 64
    t.integer  "luc"
    t.string   "muni",          :limit => 8
    t.string   "nbhd",          :limit => 16
    t.integer  "hstdcode"
    t.integer  "censusblk"
    t.string   "zip5",          :limit => 5
    t.string   "zip4",          :limit => 4
    t.integer  "case_no"
    t.text     "attorney"
    t.date     "sale_dt"
    t.text     "soldto"
    t.decimal  "sale_amt",                     :precision => 16, :scale => 4
    t.decimal  "paid_amt",                     :precision => 16, :scale => 4
    t.string   "addrln1",       :limit => 254
    t.string   "addrln2",       :limit => 254
    t.string   "city",          :limit => 128
    t.string   "statezip",      :limit => 4
    t.string   "buyer_addrno",  :limit => 254
    t.string   "buyer_addrln1", :limit => 254
    t.string   "buyer_addrln2", :limit => 254
    t.string   "buyer_city",    :limit => 128
    t.string   "buyer_state",   :limit => 4
    t.string   "buyer_zip",     :limit => 16
    t.date     "entrydate"
    t.integer  "county_id",     :limit => 8
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

  create_table "spatial_ref_sys", :id => false, :force => true do |t|
    t.integer "srid",                      :null => false
    t.string  "auth_name", :limit => 256
    t.integer "auth_srid"
    t.string  "srtext",    :limit => 2048
    t.string  "proj4text", :limit => 2048
  end

  create_table "states", :force => true do |t|
    t.string   "name",       :limit => 128
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

end
