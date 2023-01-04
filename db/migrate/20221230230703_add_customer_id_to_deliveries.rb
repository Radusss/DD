class AddCustomerIdToDeliveries < ActiveRecord::Migration[7.0]
  def change
    add_column :deliveries, :customer_id, :integer
  end
end
