class AddTrackingNumberToDeliveries < ActiveRecord::Migration[7.0]
  def change
    add_column :deliveries, :tracking_number, :string, unique: true
  end
end
