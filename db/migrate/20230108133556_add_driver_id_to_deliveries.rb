class AddDriverIdToDeliveries < ActiveRecord::Migration[7.0]
  def change
    add_column :deliveries, :driver_id, :integer
  end
end
