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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140206204920) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "child_resources", force: true do |t|
    t.integer  "parent_resource_id"
    t.boolean  "r_boolean"
    t.date     "r_date"
    t.datetime "r_datetime"
    t.decimal  "r_decimal"
    t.float    "r_float"
    t.integer  "r_integer"
    t.string   "r_string"
    t.text     "r_text"
    t.time     "r_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "controlled_versioning_version_attributes", force: true do |t|
    t.string  "version_type", null: false
    t.integer "version_id",   null: false
    t.string  "name",         null: false
    t.text    "old_value"
    t.text    "new_value"
  end

  add_index "controlled_versioning_version_attributes", ["version_type", "version_id"], name: "controlled_versioning_version_attriubtes_on_version", using: :btree

  create_table "controlled_versioning_version_children", force: true do |t|
    t.string  "version_type",                       null: false
    t.integer "version_id",                         null: false
    t.string  "versionable_type"
    t.integer "versionable_id"
    t.string  "association_name",                   null: false
    t.boolean "marked_for_removal", default: false, null: false
  end

  add_index "controlled_versioning_version_children", ["association_name"], name: "controlled_versioning_version_children_on_association", using: :btree
  add_index "controlled_versioning_version_children", ["version_type", "version_id"], name: "controlled_versioning_version_children_on_version", using: :btree
  add_index "controlled_versioning_version_children", ["versionable_type", "versionable_id"], name: "controlled_versioning_version_children_on_versionable", using: :btree

  create_table "controlled_versioning_versions", force: true do |t|
    t.string   "versionable_type",                   null: false
    t.integer  "versionable_id",                     null: false
    t.integer  "user_id"
    t.text     "notes"
    t.boolean  "initial",            default: false, null: false
    t.boolean  "marked_for_removal", default: false, null: false
    t.boolean  "accepted",           default: false, null: false
    t.boolean  "declined",           default: false, null: false
    t.boolean  "pending",            default: true,  null: false
    t.datetime "created_at"
  end

  add_index "controlled_versioning_versions", ["accepted"], name: "index_controlled_versioning_versions_on_accepted", using: :btree
  add_index "controlled_versioning_versions", ["declined"], name: "index_controlled_versioning_versions_on_declined", using: :btree
  add_index "controlled_versioning_versions", ["initial"], name: "index_controlled_versioning_versions_on_initial", using: :btree
  add_index "controlled_versioning_versions", ["pending"], name: "index_controlled_versioning_versions_on_pending", using: :btree
  add_index "controlled_versioning_versions", ["versionable_type", "versionable_id"], name: "controlled_versioning_versions_on_versionable", using: :btree

  create_table "grand_child_resources", force: true do |t|
    t.integer  "child_resource_id"
    t.boolean  "r_boolean"
    t.date     "r_date"
    t.datetime "r_datetime"
    t.decimal  "r_decimal"
    t.float    "r_float"
    t.integer  "r_integer"
    t.string   "r_string"
    t.text     "r_text"
    t.time     "r_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nonversionable_resources", force: true do |t|
    t.boolean  "r_boolean"
    t.date     "r_date"
    t.datetime "r_datetime"
    t.decimal  "r_decimal"
    t.float    "r_float"
    t.integer  "r_integer"
    t.string   "r_string"
    t.text     "r_text"
    t.time     "r_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parent_resources", force: true do |t|
    t.boolean  "r_boolean"
    t.date     "r_date"
    t.datetime "r_datetime"
    t.decimal  "r_decimal"
    t.float    "r_float"
    t.integer  "r_integer"
    t.string   "r_string"
    t.text     "r_text"
    t.time     "r_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partially_exclusive_versionable_resources", force: true do |t|
    t.boolean  "r_boolean"
    t.date     "r_date"
    t.datetime "r_datetime"
    t.decimal  "r_decimal"
    t.float    "r_float"
    t.integer  "r_integer"
    t.string   "r_string"
    t.text     "r_text"
    t.time     "r_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partially_inclusive_versionable_resources", force: true do |t|
    t.boolean  "r_boolean"
    t.date     "r_date"
    t.datetime "r_datetime"
    t.decimal  "r_decimal"
    t.float    "r_float"
    t.integer  "r_integer"
    t.string   "r_string"
    t.text     "r_text"
    t.time     "r_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string "name", null: false
  end

  create_table "versionable_resources", force: true do |t|
    t.boolean  "r_boolean"
    t.date     "r_date"
    t.datetime "r_datetime"
    t.decimal  "r_decimal"
    t.float    "r_float"
    t.integer  "r_integer"
    t.string   "r_string"
    t.text     "r_text"
    t.time     "r_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
