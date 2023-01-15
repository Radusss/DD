class Delivery < ApplicationRecord
    #attr_accessor :status, :height, :width, :depth, :street, :house_number
    belongs_to :customer
    belongs_to :driver, optional: true
    geocoded_by :address
    after_validation :geocode
    scope :inside_warehouse, -> { where(status: 'Inside Warehouse') }

    def address
        "#{street}, #{house_number}, Groningen, Netherlands"
    end


end