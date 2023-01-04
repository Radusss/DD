class AddStatusToDeliveries < ActiveRecord::Migration[7.0]
  def change
    add_column :deliveries, :status, :string
  end
end
