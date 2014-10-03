class CreateRubberStampDiffAttributes < ActiveRecord::Migration
  def change
    create_table :rubber_stamp_diff_attributes do |t|
      t.integer  :version_attribute_id, null: false
      t.integer :index
      t.string :text
      t.boolean :deletion, null: false, default: false
    end
    add_index :rubber_stamp_diff_attributes,
      :version_attribute_id,
      name: "rubber_stamp_diff_attriubtes_on_attribute"
    add_index :rubber_stamp_diff_attributes, :index
    add_index :rubber_stamp_diff_attributes, :deletion
  end
end