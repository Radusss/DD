
require 'net/http/post/multipart'
require 'net/http'
require 'json'
require 'uri'



class DeliveriesController < ApplicationController


  def index
    get_eshop_orders
    make_bids
    #if not @post_delivery["detail"] == "Order is already being delivered"
    send_labels
    pickup_eshop_deliveries
    dropoff_eshop_deliveries
    @all_eshop_orders
  end


  def create
    @delivery = Delivery.new(delivery_params)
    @delivery.status = "On the way to the warehouse"
    @delivery.tracking_number = Time.now.to_i.to_s + rand(10000..99999).to_s
    @delivery.customer = Customer.find(params[:customer_id])
    @delivery.geocode
    if @delivery.save
        redirect_to user_home_path, notice: 'Delivery was successfully created.'
    else
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
  end


  def get_eshop_orders

    debugger
    url = URI("https://pasd-webshop-api.onrender.com/api/order/")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["x-api-key"] = "7ET74P2i5YRoKF4CdSMu"

    response = http.request(request)
    @all_eshop_orders = JSON.parse(response.body)["orders"]
      
  end

  def patch_eshop_delivery(delivery_id)
    debugger
    url = URI("https://pasd-webshop-api.onrender.com/api/delivery/#{delivery_id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Patch.new(url)
    request["x-api-key"] = "7ET74P2i5YRoKF4CdSMu"
    request["Content-Type"] = "application/json"
    delivery = get_eshop_delivery(delivery_id)
    
    if delivery["status"] == "RFP"
      request.body = {status: "TRN"}.to_json
    elsif delivery["status"] == "TRN"
      request.body = {status: "DEL"}.to_json
    end

    response = http.request(request)
    @eshop_delivery = JSON.parse(response.body)
    puts @eshop_delivery 
  end



  def get_eshop_delivery(delivery_id)
    debugger
    url = URI("https://pasd-webshop-api.onrender.com/api/delivery/#{delivery_id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["x-api-key"] = "7ET74P2i5YRoKF4CdSMu"

    response = http.request(request)
    @eshop_delivery = JSON.parse(response.body)
    puts @eshop_delivery
    @eshop_delivery
  end



  def make_bids
    @eshop_accepted_deliveries = []
    @all_eshop_orders.each do |order|
      debugger
      post_eshop_delivery(order["id"]) #Bid
      @eshop_accepted_deliveries << @post_delivery if @post_delivery["status"] == "EXP" 
    end 
    @eshop_accepted_deliveries
  end

  def send_labels
    @eshop_accepted_deliveries.each do |e_delivery|
      post_eshop_label(e_delivery['id'])
    end
  end

  def pickup_eshop_deliveries
    debugger
    get_all_accepted_deliveries_ids.each do |id|
      delivery = get_eshop_delivery(id)
      patch_eshop_delivery(id) if delivery['status'] == 'RFP' 
    end
  end


  def dropoff_eshop_deliveries
    get_all_accepted_deliveries_ids.each do |id|
      delivery = get_eshop_delivery(id)
      patch_eshop_delivery(id) if delivery['status'] == 'TRN' 
    end
  end

  def get_all_accepted_deliveries_ids
    ids = []
    @eshop_accepted_deliveries.each do |e_delivery|
      ids << e_delivery['id']
    end
    ids
  end

  def post_eshop_delivery(order_id)
    debugger
    url = URI("https://pasd-webshop-api.onrender.com/api/delivery/")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = "7ET74P2i5YRoKF4CdSMu"

    price_in_cents = 1500
    request.body = { price_in_cents: price_in_cents, expected_delivery_datetime: calculate_delivery_time, order_id: order_id }.to_json

    response = http.request(request)
    @post_delivery = JSON.parse(response.body)

    while JSON.parse(response.body)["status"] == "REJ"

      break if price_in_cents <= 100
      price_in_cents = price_in_cents - 100
      request.body = { price_in_cents: price_in_cents, expected_delivery_datetime: calculate_delivery_time, order_id: order_id }.to_json
      response = http.request(request)
      @post_delivery = JSON.parse(response.body)
      puts '-------------------------------------------------------------------------------'
      puts @post_delivery
      puts '-------------------------------------------------------------------------------'

    end
    @post_delivery
  end



  def post_eshop_label(id)
    debugger

    delivery_id = id.to_s
    url = URI.parse("https://pasd-webshop-api.onrender.com/api/label?delivery_id=#{delivery_id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true



    file_path = File.join(Rails.root, "app", "assets", "images", "download.pdf")
    file = File.new(file_path, 'rb')
    pulamea = "#{url.path}?#{url.query}"

    query = {"delivery_id" => delivery_id}
    req = Net::HTTP::Post::Multipart.new(pulamea, {"labelFile" => UploadIO.new(file, "application/pdf")})

    req.add_field "accept", "application/json"
    req.add_field "x-api-key", "7ET74P2i5YRoKF4CdSMu"
    http.set_debug_output $stderr

    response = http.request(req)

    puts '-------------------------------------------------------------------------------'
    puts response
    @post_label = JSON.parse(response.body)
    puts @post_label
    puts '-------------------------------------------------------------------------------'

  end


  def load_car
      
      # Select the 10 oldest deliveries with the status "Inside warehouse"
      @deliveries = Delivery.where(status: 'Inside Warehouse').order(created_at: :asc).limit(10)

      # Update the status of the selected deliveries to "Loading car"
      @deliveries.update_all(status: 'Loading car', driver_id: current_user.id)

      # Redirect to the driver_home page
      redirect_to '/driver_home'
  end

  def start_delivery
      
    # Select the 10 oldest deliveries with the status "Inside warehouse"
    @deliveries = Delivery.where(status: 'Loading car', driver_id: current_user.id)

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

  def calculate_delivery_time
    current_time = Time.now
    expected_delivery_datetime = current_time + (1 * 24 * 60 * 60)
    expected_delivery_datetime = expected_delivery_datetime.iso8601
  end

  def delivery_params
      params.require(:delivery).permit(:street, :house_number, :height, :width, :depth)
  end


end