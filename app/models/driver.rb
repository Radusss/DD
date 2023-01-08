class Driver < User
  attr_accessor :vehicle_id
  has_many :deliveries
  scope :drivers, -> { where(role: 'driver') }

  def load_inventory
  end
  
end
