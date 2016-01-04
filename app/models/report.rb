class Report < ActiveRecord::Base
  has_many :report_favoritings
  has_many :favoriting_users, through: :report_favoritings, source: :user
  has_many :report_runs

  ALL_KINDS = [
    {permalink: 'vendor_spend', name: 'Vendor Spend', description: "Provides analysis of the total spending on your Vendors.  Useful to understand who are your top Vendors to negotiate contracts with.", groups: 'spending' },
    {permalink: 'category_spend', name: 'Category Spend', description: "Understand your Hotel's spending by Category. Analyze which categories comprise most of your hotel's spending", groups: 'spending' },
    {permalink: 'items_spend', name: 'Items Spend', description: "Analyze which items comprise 80% of your spending. Optimize the procurement and inventory to reduce costs.", groups: 'spending' },
    {permalink: 'purchase_history_report', name: 'Purchase History Report', description: "Understand your Hotel's spending by Category. Analyze which categories comprise most of your hotel's spending", groups: 'purchases' },
    {permalink: 'budget_vs_spend', name: 'Budget vs Spend', description: "Description goes here", groups: 'budget' },
    {permalink: 'cpor_analysis', name: 'CPOR Analysis', description: "Description goes here", groups: 'budget' },
    {permalink: 'vendor_list', name: 'Vendor List', description: "Description goes here", groups: 'misc' },
    {permalink: 'list_item_coverage', name: 'List Item Coverage', description: "Description goes here", groups: 'misc' },
    {permalink: 'items_consumption', name: 'Items Consumption', description: "Consumption Report allows you to analyze the frequency, size and value of your Ordering for individual items to understand and compare your consumption between periods.", groups: 'purchases,misc' },
    {permalink: 'item_price_variance', name: 'Item Price Variance', description: "Provides data from Item's Received Orders to analyze the variation in the PO price and the Actual price an item is received at.", groups: 'spending,misc' },
    {permalink: 'inventory_vs_ordering', name: 'Inventory vs Ordering', description: "...", groups: 'purchases, misc' }
  ]

  def groups_as_array
    self.groups.split(',').map(&:strip)
  end

  def toggle_favorited_by!(user)
    if favorited_by?(user)
      favoriting_users.delete(user)
    else
      favoriting_users << user
    end
  end

  def favorited_by?(user)
    favoriting_users.include?(user)
  end

  def record_run_by!(user)
    report_runs.create(user:user)
  end

  def last_run
    @last_run ||= report_runs.order(:created_at).last
  end

  def last_run_by_name
    last_run.user.name
  end

 def last_run_at
   last_run.created_at
 end
end
