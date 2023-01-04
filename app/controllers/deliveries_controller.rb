class DeliveriesController < ApplicationController
    def create
        @delivery = Delivery.new(delivery_params)
        @delivery.status = "On the way to the warehouse"
        @delivery.tracking_number = Time.now.to_i.to_s + rand(10000..99999).to_s
        @delivery.customer = Customer.find(params[:customer_id])
  
        if @delivery.save
            redirect_to user_home_path, notice: 'Delivery was successfully created.'
        else
            #render :new
            puts 'NOPE-------------------'
            puts "Errors: #{@delivery.errors.full_messages}"
        end
    end
  
    private
    def delivery_params
        params.require(:delivery).permit(:street, :house_number, :height, :width, :depth)
    end
  end