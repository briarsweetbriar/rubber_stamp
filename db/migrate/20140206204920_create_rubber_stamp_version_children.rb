# This migration comes from rubber_stamp (originally 20140206165210)
class CreateRubberStampVersionChildren < ActiveRecord::Migration
  def change
    create_table :rubber_stamp_version_children do |t|
      t.string   :version_type, null: false
      t.integer  :version_id, null: false
      t.string   :versionable_type
      t.integer  :versionable_id
      t.string   :association_name, null: false

      t.boolean  :marked_for_removal, null: false, default: false
    end
    add_index :rubber_stamp_version_children,
      :association_name,
      name: "rubber_stamp_version_children_on_association"
    add_index :rubber_stamp_version_children,
      [:version_type, :version_id],
      name: "rubber_stamp_version_children_on_version"
    add_index :rubber_stamp_version_children,
      [:versionable_type, :versionable_id],
      name: "rubber_stamp_version_children_on_versionable"
  end
end