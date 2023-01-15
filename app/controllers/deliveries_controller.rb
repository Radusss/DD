
require 'net/http/post/multipart'
require 'net/http'
require 'json'
require 'uri'



class DeliveriesController < ApplicationController


    def index
      get_eshop_deliveries
      post_eshop_delivery
      post_eshop_label
      @all_eshop_deliveries
    end

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

    def get_eshop_deliveries

      debugger
      url = URI("https://pasd-webshop-api.onrender.com/api/order/")
  
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
  
      request = Net::HTTP::Get.new(url)
      request["x-api-key"] = "7ET74P2i5YRoKF4CdSMu"
  
      response = http.request(request)
      @all_eshop_deliveries = JSON.parse(response.body)["orders"]
        
    end

    def post_eshop_delivery
      debugger
      url = URI("https://pasd-webshop-api.onrender.com/api/delivery/")
  
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
  
      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/json"
      request["x-api-key"] = "7ET74P2i5YRoKF4CdSMu"

      price_in_cents = 1500
      request.body = { price_in_cents: price_in_cents, expected_delivery_datetime: calculate_delivery_time, order_id: @all_eshop_deliveries.first["id"] }.to_json
  
      response = http.request(request)

      while JSON.parse(response.body)["status"] == "REJ"

        break if price_in_cents <= 100
        price_in_cents = price_in_cents - 100
        request.body = { price_in_cents: price_in_cents, expected_delivery_datetime: calculate_delivery_time, order_id: @all_eshop_deliveries.first["id"] }.to_json
        response = http.request(request)
        @post_delivery = JSON.parse(response.body)
        puts '-------------------------------------------------------------------------------'
        puts @post_delivery
        puts '-------------------------------------------------------------------------------'

      end
        
    end

    def post_eshop_label
      debugger

      delivery_id = @all_eshop_deliveries.first["id"]
      url = URI("https://pasd-webshop-api.onrender.com/api/label?delivery_id=#{delivery_id}")
    
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
  
      file_path = File.join(Rails.root, "app", "assets", "images", "label.txt")
      file = File.new(file_path, 'rb')
      req = Net::HTTP::Post::Multipart.new url.path,
                                           "labelFile" => UploadIO.new(file, "text/plain"),
                                           "delivery_id" => delivery_id.to_s
      

      req.add_field "accept", "application/json"
      req.add_field "x-api-key", "7ET74P2i5YRoKF4CdSMu"

      response = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == 'https') do |http|
        http.request(req)
      end

      puts '-------------------------------------------------------------------------------'
      puts response
      @post_label = JSON.parse(response.body)
      puts @post_label
      puts '-------------------------------------------------------------------------------'

    end


    def load_car
        
        # Select the 10 oldest deliveries with the status "Inside warehouse"
        @deliveries = Delivery.where(status: 'Inside Warehouse').order(created_at: :asc).limit(10)
      
        # Update the status of the selected deliveries to "In car"
        @deliveries.update_all(status: 'On the way to the destination', driver_id: current_user.id)


        # Redirect to the driver_home page
        redirect_to '/driver_home'
    end

    def done
        @delivery = Delivery.find(params[:id])
        @delivery.update(status: 'Delivered')
        redirect_to '/driver_home'
    end
  
    private

    def generate_multipart_body(file_path, file_type, file_name)
      boundary = "your_boundary"
      file = File.new(file_path)
      body = []
      body << "--#{boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"labelFile\"; filename=\"#{file_name}\"\r\n"
      body << "Content-Type: #{file_type}\r\n\r\n"
      body << file.read
      body << "\r\n--#{boundary}--\r\n"
      body.join
    end

    def calculate_delivery_time
      current_time = Time.now
      expected_delivery_datetime = current_time + (1 * 24 * 60 * 60)
      expected_delivery_datetime = expected_delivery_datetime.iso8601
    end

    def delivery_params
        params.require(:delivery).permit(:street, :house_number, :height, :width, :depth)
    end


  end