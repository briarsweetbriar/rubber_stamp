# This migration comes from controlled_versioning (originally 20140206165205)
class CreateControlledVersioningVersionAttributes < ActiveRecord::Migration
  def change
    create_table :controlled_versioning_version_attributes do |t|
      t.string   :version_type, null: false
      t.integer  :version_id, null: false
      t.string :name, null: false
      t.text :old_value
      t.text :new_value
    end
    add_index :controlled_versioning_version_attributes,
      [:version_type, :version_id],
      name: "controlled_versioning_version_attriubtes_on_version"
  end
end