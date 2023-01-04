class Customer < User
    has_many :deliveries
    serialize :delivery_ids, Array
end