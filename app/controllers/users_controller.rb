class UsersController < ApplicationController
    def home
        if current_user.role == "driver"
            render "driver_home"
        elsif current_user.role == "ww"
            render "ww_home"
        else
            @user_deliveries = Delivery.where(customer_id: current_user.id)
            @user_deliveries.each do |delivery|
                puts delivery.attributes
            end
            render "standard_home" 
        end
    end

    def charge
    end
end
