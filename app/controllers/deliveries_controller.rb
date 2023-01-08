class DeliveriesController < ApplicationController
    def create
        @delivery = Delivery.new(delivery_params)
        @delivery.status = "On the way to the warehouse"
        @delivery.tracking_number = Time.now.to_i.to_s + rand(10000..99999).to_s
        @delivery.customer = Customer.find(params[:customer_id])
        @delivery.geocode

        puts @delivery.latitude
        puts @delivery.longitude
        puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        # @delivery.driver = -1
        if @delivery.save
            redirect_to user_home_path, notice: 'Delivery was successfully created.'
        else
            #render :new
            puts 'NOPE-------------------'
            puts "Errors: #{@delivery.errors.full_messages}"
        end
    end

    def update_status
        tracking_number = params[:tracking_number]
        delivery = Delivery.find_by(tracking_number: tracking_number)
      
        if delivery.present?
          delivery.status = 'Inside Warehouse'
          delivery.save
        else
          flash[:error] = "Delivery with tracking number #{tracking_number} not found"
        end
      
        redirect_to '/ww_home'
        #render json: { delivery: delivery }

      end

      def load_car
        puts '-------------------------------------------------------------------sadasdasdasdasd'
        # Select the 10 oldest deliveries with the status "Inside warehouse"
        @deliveries = Delivery.where(status: 'Inside Warehouse').order(created_at: :asc).limit(10)
      
        # Update the status of the selected deliveries to "In car"
        @deliveries.update_all(status: 'On the way to the destination', driver_id: current_user.id)


        # Redirect to the driver_home page
        redirect_to '/driver_home'
    end
  
    private

    def delivery_params
        params.require(:delivery).permit(:street, :house_number, :height, :width, :depth)
    end


  end