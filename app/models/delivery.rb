class Delivery < ApplicationRecord
    #attr_accessor :status, :height, :width, :depth, :street, :house_number
    belongs_to :customer
end