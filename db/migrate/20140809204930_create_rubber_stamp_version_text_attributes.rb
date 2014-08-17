class CreateRubberStampVersionTextAttributes < ActiveRecord::Migration
  def change
    create_table :rubber_stamp_version_text_attributes do |t|
      t.integer  :version_attribute_id, null: false
      t.integer :index
      t.string :text
      t.boolean :deletion, null: false, default: false
    end
    add_index :rubber_stamp_version_text_attributes,
      :version_attribute_id,
      name: "rubber_stamp_version_text_attriubtes_on_attribute"
    add_index :rubber_stamp_version_text_attributes, :index
    add_index :rubber_stamp_version_text_attributes, :deletion
  end
end