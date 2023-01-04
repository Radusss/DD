class CreateWarehouses < ActiveRecord::Migration[7.0]
  def change
    create_table :warehouses do |t|
      t.integer :delivery_id
      t.integer :warehouse_worker_id
      t.timestamps
    end
  end
end
