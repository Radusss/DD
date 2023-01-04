class ActiveOrder < ApplicationRecord
    belongs_to :driver
    has_many :deliveries
  end