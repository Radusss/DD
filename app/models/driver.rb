class Driver < User
    attr_accessor :car_id
    has_many :active_orders
  end
