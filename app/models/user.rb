class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  #has many :deliveries
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  attr_accessor :name, :role 
end
