class AddActiveOrderIdToDeliveries < ActiveRecord::Migration[7.0]
  def change
    add_column :deliveries, :active_order_id, :integer, null: true
  end
end
