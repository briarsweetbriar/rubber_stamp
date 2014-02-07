class CreateHandlerResources < ActiveRecord::Migration
  def change
    create_table :handler_resources do |t|
      t.boolean :r_boolean
      t.date :r_date
      t.datetime :r_datetime
      t.decimal :r_decimal
      t.float :r_float
      t.integer :r_integer
      t.string :r_string
      t.text :r_text
      t.time :r_time

      t.integer :accept_count, null: false, default: 0
      t.integer :decline_count, null: false, default: 0
      t.integer :accepted_revisions_count, null: false, default: 0
      t.integer :declined_revisions_count, null: false, default: 0

      t.boolean :accepted, null: false, default: false
      t.boolean :declined, null: false, default: false

      t.timestamps
    end
  end
end
