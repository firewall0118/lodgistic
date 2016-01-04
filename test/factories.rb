require 'factory_girl'

FactoryGirl.define do
  factory :property do
    sequence(:name) {|n| "Hotel #{n}" }
  end

  factory :vendor do
    name { Faker::Vendor.name }
  end

  factory :vendor_item do
    association :vendor
    price 200
    items_per_box 100
  end

  factory :tag do
    sequence(:name) {|n| "Tag #{n}" }
    # item(:item_with_vendor_item)
  end

  factory :category do
    sequence(:name) {|n| "Category #{n}" }
    # before(:create) do |list, evaluator|
    #   list.items << FactoryGirl.create(:item)
    # end
	end

	factory :location do
    before(:create) do |location, evaluator|
      location.items << create(:item)
    end
	  sequence(:name) {|n| "Location #{n}" }
    # after(:build) do |location|
    #   location.items << build(:item_with_vendor_item)
    # end
	end

  factory :list do
    before(:create) do |list, evaluator|
      list.items << create(:item)
    end
    sequence(:name) {|n| "List #{n}" }
  end

  factory :unit do
    sequence(:name) {|n| "#{n}nit" } # TODO this is broken, for some reason factorygirl tries to create this twice
    description { Faker::Lorem.sentence }
  end

  factory :purchase_order do
    association :purchase_request
    association :user
    vendor{ FactoryGirl.create(:vendor, vendor_items: [FactoryGirl.create(:vendor_item)]) }

    factory :purchase_order_with_item_orders do
      before(:create) do |purchase_order|
        purchase_order.item_orders << build(:item_order)
        purchase_order.item_orders << build(:item_order)
        purchase_order.item_orders << build(:item_order)
      end
    end
  end

  factory :item_order do
    association :item, factory: :item_with_vendor_item
    association :item_request
    association :purchase_order
    quantity 20
    price 10
  end

  factory :purchase_receipt do
    association :user
    association :purchase_order
  end
  
  factory :budget do
    association :user
    association :category
    amount 100
    month Date.today.month
    year Date.today.year
  end

  factory :item_request do
    association :item, factory: :item_with_vendor_item
    association :purchase_request
    quantity 250
    count 100
    part_count 25
  end

  factory :item_receipt do
    association :purchase_receipt
    association :item_order
    association :item, factory: :item_with_vendor_item
    quantity 250
    price 200
  end


  factory :notification do
    association :user, factory: :user
    association :property, factory: :property
  end

  factory :user_role do
    association :property
    association :user
  end

  factory :role do
    sequence(:name) {|n| "Role #{n}" }
  end

# Read about factories at https://github.com/thoughtbot/factory_girl
end
