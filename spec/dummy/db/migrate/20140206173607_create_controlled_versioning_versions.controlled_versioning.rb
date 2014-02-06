# This migration comes from controlled_versioning (originally 20140206165158)
class CreateControlledVersioningVersions < ActiveRecord::Migration
  def change
    create_table :controlled_versioning_versions do |t|
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
    end
    add_index :controlled_versioning_versions, :initial
    add_index :controlled_versioning_versions, :accepted
    add_index :controlled_versioning_versions, :declined
    add_index :controlled_versioning_versions, :pending
    add_index :controlled_versioning_versions,
      [:versionable_type, :versionable_id],
      name: "controlled_versioning_versions_on_versionable"
  end
end