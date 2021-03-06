class Trade
  include Mongoid::Document

  attr_accessor :trade_params, :survivor_1, :survivor_2, :status, :message

  def initialize(params)
    super

    @survivor_1   = Survivor.find(params['survivor_1']['id'])
    @survivor_2   = Survivor.find(params['survivor_2']['id'])

    @trade_params = [params['survivor_1'], params['survivor_2']]
  end

  def process  
    validate_survivors
    validate_resources
    validate_balance
    trade_resources
  rescue Exception => error
    @status  = :conflict
    @message = error.message
    return false
  end

  private

  def validate_survivors
  	survivors.each_with_index do |survivor, index|
  		if survivor.blank?
  			raise "Survivor with id #{trade_params[index]['id']} does not exist"
  		end

  		if survivor.infected?
      	raise "#{survivors[index].name} is infected"
    	end
  	end
  end

  def validate_resources
  	survivors.each_with_index do |survivor, index|
  		unless survivor.has_enough_resources?(trade_params[index]['resources'])
  			raise "#{survivor.name} doesn't have enough resources"
  		end
  	end
  end

  def validate_balance
    survivor_1_points = Resource.points_sum(trade_params[0]['resources']) 
    survivor_2_points = Resource.points_sum(trade_params[1]['resources'])

    if survivor_1_points != survivor_2_points
      raise "Resources points is not balanced both sides"
    end
  end

  def trade_resources
    survivor_1.transfer_resource_to(survivor_2, trade_params[0]['resources'])
    survivor_2.transfer_resource_to(survivor_1, trade_params[1]['resources'])

    @status  = :success
    @message = 'Trade successfully completed'
  end

  def survivors
  	[survivor_1, survivor_2]
  end
end
