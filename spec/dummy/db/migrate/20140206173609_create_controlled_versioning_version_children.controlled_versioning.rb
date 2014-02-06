# This migration comes from controlled_versioning (originally 20140206165210)
class CreateControlledVersioningVersionChildren < ActiveRecord::Migration
  def change
    create_table :controlled_versioning_version_children do |t|
      t.string   :version_type, null: false
      t.integer  :version_id, null: false
      t.string   :versionable_type
      t.integer  :versionable_id

      t.boolean  :marked_for_removal, null: false, default: false
    end
    add_index :controlled_versioning_version_children,
      [:version_type, :version_id],
      name: "controlled_versioning_version_children_on_version"
    add_index :controlled_versioning_version_children,
      [:versionable_type, :versionable_id],
      name: "controlled_versioning_version_children_on_versionable"
  end
end