class CodeLocationSubscription < FisbotApi
  def initialize(code_location_id)
    @endpoint = 'subscriptions'
    @data = { code_location_id: code_location_id }
  end
end
