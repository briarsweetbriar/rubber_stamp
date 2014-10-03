# This migration comes from rubber_stamp (originally 20140206165158)
class CreateRubberStampVersions < ActiveRecord::Migration
  def change
    create_table :rubber_stamp_versions do |t|
      t.string   :versionable_type, null: false
      t.integer  :versionable_id,   null: false

      t.integer  :user_id

      t.text     :notes

      t.boolean  :initial, null: false, default: false

      t.boolean  :marked_for_removal, null: false, default: false

      t.boolean  :accepted, null: false, default: false
      t.boolean  :declined, null: false, default: false
      t.boolean  :pending, null: false, default: true

      t.datetime :created_at
      t.datetime :accepted_at
    end
    add_index :rubber_stamp_versions, :initial
    add_index :rubber_stamp_versions, :accepted
    add_index :rubber_stamp_versions, :declined
    add_index :rubber_stamp_versions, :pending
    add_index :rubber_stamp_versions,
      [:versionable_type, :versionable_id],
      name: "rubber_stamp_versions_on_versionable"
    add_index :rubber_stamp_versions, :created_at
    add_index :rubber_stamp_versions, :accepted_at
  end
end