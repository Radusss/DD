class CreateDeliveries < ActiveRecord::Migration[7.0]
  def change
    create_table :deliveries do |t|
      t.string :street
      t.string :house_number
      t.string :height
      t.string :width
      t.string :depth
      t.timestamps
    end
  end
end
