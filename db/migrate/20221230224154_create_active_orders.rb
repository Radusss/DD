class CreateActiveOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :active_orders do |t|

      t.timestamps
    end
  end
end
