class UsersController < ApplicationController
    def home
        #@email = current_user.email
        puts "Current user: #{current_user.inspect} -------------------------------------------------------------------------------------------------------------------------------------------------------------"
        @user_deliveries = Delivery.where(customer_id: current_user.id)
        @user_deliveries.each do |delivery|
            puts delivery.attributes
        end
    end
end