class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, [Location, Category]

    if user.corporate_id?
      if Property.current
        corporate(user)
        cannot :access_corporate_app, User
      else
        can :access_corporate_app, User
      end
    else
      send user.current_property_role.method_name, user
      cannot :access_corporate_app, User
    end
  end

  def gm(user)
    can :settings, Property
    can :manage, Corporate::Connection
    can :manage, List
    can [:new, :create, :edit, :update, :index, :inventory_print], PurchaseRequest
    can :approve, PurchaseRequest do |pr|
      pr.total_price <= user.current_property_user_role.order_approval_limit
    end
    can [:new, :create], PurchaseReceipt
    can :manage, PurchaseOrder
    
    can [:index, :show, :new, :create], User
    can [:edit], User do |u|
      Property.current.users.include?(u)
    end
    can [:update], User do |u|
      Property.current.users.include?(u) && !u.corporate_id?
    end
    can [:destroy], User do |u|
      !u.corporate_id?
    end

    can :manage_restricted_attributes, User

    can :manage, Item
    can :manage, Vendor
    can :manage, Department
    can :manage, Budget
  end

  def agm(user)
    can :manage, List
    can :manage, Vendor
    can :manage, Department
    can [:new, :create, :edit, :update, :index, :inventory_print], PurchaseRequest
    can [:new, :create], PurchaseReceipt
    can :manage, PurchaseOrder
    can :approve, PurchaseRequest do |pr|
      pr.total_price <= user.current_property_user_role.order_approval_limit
    end
    can :read, User do |u|
      Property.current.users.include?(u)
    end
    can :update, User, id: user.id
    can :manage, Item
  end

  def corporate(user)
    can :index, [Vendor, Department]
    can :manage, User

    cannot :manage, List
    can [:edit, :update], PurchaseRequest do |pr|
      highest_gm_approval_limit = Role.gm.user_roles.order(order_approval_limit: :desc).limit(1).pluck(:order_approval_limit).first
      pr.state == 'completed' && pr.total_price > highest_gm_approval_limit
    end
    cannot :manage, PurchaseOrder

    # can :manage, User do |u|
    #   Property.current.users.include?(u)
    # end
    # cannot [:update, :destroy], User do |u|
    #   u.corporate_id?
    # end

    can [:index, :show, :new, :create], User
    cannot [:edit], User do |u|
      !Property.current.users.include?(u)
    end
    cannot [:update], User do |u|
      !Property.current.users.include?(u) || u.corporate_id?
    end
    cannot [:destroy], User do |u|
      u.corporate_id?
    end

    can :manage_restricted_attributes, User

    can [:index, :edit], Item
  end

  def manager(user)
    can [:index, :edit], [Vendor, Department]
    can :manage, List, user_id: user.id
    can [:new, :create, :edit, :update, :index, :inventory_print], PurchaseRequest, user_id: user.id
    can :approve, PurchaseRequest do |pr|
      pr.total_price <= user.current_property_user_role.order_approval_limit && pr.user_id == user.id
    end
    can :read, User do |u|
      Property.current.users.include?(u)
    end
    can :update, User, id: user.id
    cannot [:update, :destroy], User do |u|
      u.corporate_id?
    end
    can :manage, PurchaseOrder do |po|
      po.purchase_request.user_id == user.id
    end
    can [:new, :create], PurchaseReceipt do |pr|
      pr.purchase_order.purchase_request.user_id == user.id
    end

    can [:new, :index, :create, :edit], Item
    can [:change, :update], Item do |item| # :change - for checking inside form template (manager edit all items, but save changes only for certain)
      ItemTag.where(tag_id: user.category_ids.uniq ).map(&:item_id).include? item.id
    end
    can [:change], Item do |item|
      item.new_record?
    end
    can :index, Budget
  end
end
