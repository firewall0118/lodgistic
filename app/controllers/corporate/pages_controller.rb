class Corporate::PagesController < Corporate::ApplicationController
  include ActionView::Helpers::NumberHelper
  respond_to :html, :json
  
  def dashboard
    @properties_count = current_corporate.properties.count

    load_spend_by_hotel_chart_data
    load_approval_requests_data
  end
  
  def spend_budget_by_hotel
    if params[:range] == 'year'
      @from = Date.today.beginning_of_year
      @to = Date.today.end_of_year
    elsif
      @from = Date.today.beginning_of_month
      @to = Date.today.end_of_month
    end
    
    @data = {spend: [], budget: []}
    @hotels = current_corporate.properties.pluck(:name)
    current_corporate.properties.each do |prop|
      Property.current_id = prop
      total_spent = PurchaseReceipt.includes(item_receipts: :item).where(created_at: @from..@to).map(&:total_w_freight).reduce(&:+)
      budgets = Budget.where(year: Date.today.year)
      budgets = budgets.where(month: Date.today.month) unless params[:range] == 'year'
      total_budget = budgets.sum(:amount)
      @data[:spend] << total_spent.to_f
      @data[:budget] << total_budget.to_f
    end
    Property.current_id = nil
    
    render json: {hotels: @hotels, data: @data}
  end

  private
  
  def load_spend_by_hotel_chart_data
    @may_or_later = Time.now.month >= 5
    from = @may_or_later ? Date.new(Time.now.year) : (Date.current - 5.month).beginning_of_month
    if ((current_corporate.properties.any?) && (first_hotel_created_at = current_corporate.properties.minimum(:created_at).beginning_of_month.to_date) && from < first_hotel_created_at)
      from = first_hotel_created_at
    end
    to = Date.current

    @spend_by_hotel_data = { categories: [], series: current_corporate.properties.map{ |prop| {id: prop.id, name: prop.name, data: [] } }}
    @hotel_totals = []

    current_corporate.properties.each do |prop|
      Property.current_id = prop.id
      @hotel_totals << { name: prop.name, total: PurchaseReceipt.includes(item_receipts: :item).where(created_at: from..to).map(&:total_w_freight).reduce(&:+).to_f }
    end

    (from..to).map(&:beginning_of_month).uniq.each do |month|
      @spend_by_hotel_data[:categories] << month.strftime( @may_or_later ? "%b" : "%b %y" )
      current_corporate.properties.each do |prop|
        Property.current_id = prop.id
        @spend_by_hotel_data[:series].find{ |data_block| data_block[:id] == prop.id }[:data] << PurchaseReceipt.includes(item_receipts: :item).where(created_at: month..month + 1.month).map(&:total_w_freight).reduce(&:+).to_f
      end
    end

    Property.current_id = nil
    @hotel_totals_columns = @hotel_totals.in_groups_of(2, false)
  end

  def load_approval_requests_data
    @requests_for_properties = []
    current_corporate.properties.each do |prop|
      Property.current_id = prop.id
      requests = PurchaseRequest.where(state: 'completed').without_inventory_finished.order(updated_at: :desc).select do |pr|
        pr.total_price > prop.highest_gm_approval_limit
      end
      @requests_for_properties << { prop: prop, requests: requests } if requests.any?
    end
    Property.current_id = nil
  end

end
