class AddDeliveryIdsToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :delivery_ids, :text
  end
end
