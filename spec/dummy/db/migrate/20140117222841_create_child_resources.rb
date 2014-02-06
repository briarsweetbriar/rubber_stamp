class CreateChildResources < ActiveRecord::Migration
  def change
    create_table :child_resources do |t|
      t.integer :parent_resource_id
      
      t.boolean :r_boolean
      t.date :r_date
      t.datetime :r_datetime
      t.decimal :r_decimal
      t.float :r_float
      t.integer :r_integer
      t.string :r_string
      t.text :r_text
      t.time :r_time

      t.timestamps
    end
  end
end
