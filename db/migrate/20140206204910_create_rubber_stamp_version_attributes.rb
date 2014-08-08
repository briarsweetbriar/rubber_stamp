# This migration comes from rubber_stamp (originally 20140206165205)
class CreateRubberStampVersionAttributes < ActiveRecord::Migration
  def change
    create_table :rubber_stamp_version_attributes do |t|
      t.string   :version_type, null: false
      t.integer  :version_id, null: false
      t.string :name, null: false
      t.text :old_value
      t.text :new_value
    end
    add_index :rubber_stamp_version_attributes,
      [:version_type, :version_id],
      name: "rubber_stamp_version_attriubtes_on_version"
  end
end