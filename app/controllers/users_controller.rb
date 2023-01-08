class UsersController < ApplicationController
    def home
        if current_user.role == "driver"
            # Render the driver's home page
            render "driver_home"
        elsif current_user.role == "ww"
            # Render the warehouse worker's home page
            render "ww_home"
        else
            # Render the standard user's home page
            @user_deliveries = Delivery.where(customer_id: current_user.id)
            @user_deliveries.each do |delivery|
                puts delivery.attributes
            end
            render "standard_home" 
        end
    end
end
