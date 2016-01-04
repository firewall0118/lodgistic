class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_date_range, except: [:index, :favorites, :favorite, :show]
  add_breadcrumb I18n.t("controllers.reports.reports"), :reports_path

  def favorites
    add_breadcrumb t("controllers.reports.favorites")
    @title = t("controllers.reports.favorite_reports")
    @reports = current_user.favorite_reports
    render :index
  end

  def index
    @title = t("controllers.reports.reports_listing")
    @reports = Report.all
  end

  def favorite
    @report = Report.find(params[:id])
    @report.toggle_favorited_by!(current_user)
    render json: true
  end

  def show
    @report = Report.find_by(permalink: params[:id])
    @report.record_run_by!(current_user)
    add_breadcrumb @report.name
    render @report.permalink
  end

  def item_price_variance_data
    results = []
    Item.all.each do |item|
      ipv = ItemPriceVariance.new(item, @from..@to)
      row = {}
      row[:item_id]  = item.id
      row[:vendor]   = item.vendor_ids.first
      row[:category] = item.category_ids.first
      row[:lists]    = item.list_ids.join(',')
      row[:item_name] = item.name
      row[:num_orders] = ipv.num_orders
      next if row[:num_orders] == 0
      row[:average_price] = ipv.average_price
      row[:average_variance] = ipv.average_variance
      row[:increase] = ipv.increase
      next if row[:average_variance] == '0' && row[:increase] == '0'
      results << row
    end

    render json: results
  end

  def vendor_spend_data
    total_spend = PurchaseReceipt.where(created_at: @from..@to).map(&:total_w_freight).reduce(&:+)
    result = []

    Vendor.all.each do |vendor|
      row = {vendor_name: vendor.name }
      receipts = vendor.purchase_receipts.where(created_at: @from..@to)
      row[:num_orders] = receipts.map(&:purchase_order_id).uniq.count
      spend = receipts.map(&:total_w_freight).reduce(&:+)

      next unless spend
      row[:spend] = spend.to_s
      row[:percentage_of_spend] = spend ? spend / total_spend * 100 : 0
      result << row
    end

    render json: result.to_json
  end

  ### ITEM CONSUMED REPORT ========>

  def items_consumption_data
    result = []
    months_count_in_the_range = ((@to - @from).to_f / (24 *60 *60) / 30.44).round # 30.44 avg days number in month

    Item.where(created_at: @from..@to).includes(:purchase_orders, :vendors).load.each do |item|
      row    = {name: item.name}
      orders = item.purchase_orders.joins(:purchase_receipts).where(created_at: @from..@to).uniq
      next unless orders.any?
      row[:item_id]  = item.id
      row[:vendor]   = item.vendors.first.name
      row[:category] = item.categories.first.name
      row[:lists]    = item.lists.pluck(:name).join(',')
      row[:last_inventory_time] = item.purchase_requests.where(created_at: @from..@to).order(created_at: :desc).limit(1).first.try(:created_at).try(:to_i)
      row[:avg_monthly_orders]  = (orders.count.to_f / months_count_in_the_range * 100).round / 100.0
      item_receipts             = item.item_receipts.where(created_at: @from..@to)
      row[:avg_order_qty]  = "#{ (item_receipts.sum(:quantity) / orders.count.to_f * 100).round / 100.0 } <br><span class='text-muted semibold'>#{ item.unit.name }</span>"
      row[:avg_order_cost] = item_receipts.any? ? "#{I18n.t :currency}#{ (item_receipts.map(&:total).map(&:to_f).inject(&:+) / orders.count.to_f * 100).round / 100.0 }" : ""

      result << row
    end
    render json: result.to_json
  end

  def item_orders_chart_data
    # @to - @from <-- current period selected, for the chart we need to consider it and 5 periods (of the same size) before
    result = []
    item = Item.find(params[:id])
    months_count_in_the_range = ((@to - @from).to_f / (24 *60 *60) / 30.44).round # 30.44 avg days number in month
    periods_count = {3 => 5, 6 => 3, 12 => 2}[months_count_in_the_range]

    chart_data_start = @from - (months_count_in_the_range * periods_count).month
    chart_date_check_point = chart_data_start
    while(chart_date_check_point < @to)
      orders = item.purchase_orders.joins(:purchase_receipts).where(created_at: chart_date_check_point..chart_date_check_point + months_count_in_the_range.month)
      result << [chart_date_check_point.to_i, orders.count]
      chart_date_check_point += months_count_in_the_range.month
    end
    render json: result.to_json
  end

  ### <======== ITEM CONSUMED REPORT

  def category_spend_data
    total_spend = PurchaseReceipt.where(created_at: @from..@to).map(&:total_w_freight).reduce(&:+)
    result = []

    Category.includes(:items).load.each do |category|
      item_ids = category.item_ids
      next if item_ids.count == 0
      row = {category_name: category.name }
      receipts = PurchaseReceipt.include_items(item_ids).where(created_at: @from..@to)
      row[:num_orders] = receipts.map(&:purchase_order_id).uniq.count
      spend = receipts.map { |receipt| receipt.total(item_ids) }.reduce(&:+)

      next unless spend
      row[:spend] = spend.to_s
      row[:percentage_of_spend] = spend / total_spend * 100
      result << row
    end
    
    render json: result.to_json
  end

  def items_spend_data
    total_spend = PurchaseReceipt.where(created_at: @from..@to).map(&:total_w_freight).reduce(&:+)
    result = []

    Item.all.each do |item|
      row = {name: item.name }
      receipts = PurchaseReceipt.include_items([item.id]).where(created_at: @from..@to)
      row[:num_orders] = receipts.map(&:purchase_order_id).uniq.count
      spend = receipts.map { |receipt| receipt.total([item.id]) }.reduce(&:+)
      next unless spend
      row[:spend] = spend.to_s
      row[:percentage_of_spend] = spend * 100 / total_spend
      result << row
    end
    render json: result.to_json
  end

  def inventory_vs_ordering_data
    results = []
    Item.all.each do |item|
      ivo = InventoryVsOrdering.new(item, @from..@to)
      row = {}
      row[:item_id]  = item.id
      row[:locations] = item.location_ids.join(',')
      row[:category] = item.category_ids.first
      row[:lists]  = item.list_ids.join(',')
      row[:item_name] = item.name
      row[:avg_orders] = ivo.average_orders
      row[:avg_counts] = ivo.average_counts
      next if row[:avg_orders] == '0.00' and row[:avg_counts] == '0.00'
      row[:last_count_at] = ivo.last_count_at
      row[:last_order_at] = ivo.last_order_at
    
      results << row
    end

    render json: results
  end

  private

  def get_date_range
    @from = params[:from] || Date.today.to_s
    @from = Date.parse(@from).beginning_of_day
    @to   = params[:to] || Date.today.to_s
    @to   = Date.parse(@to).end_of_day
  end
end
