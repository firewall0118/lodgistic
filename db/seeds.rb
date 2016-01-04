ActionMailer::Base.delivery_method = :test
#ActionMailer::Base.delivery_method = :letter_opener

class ActiveRecord::Base     
  def self.find_or_initialize_many(hashes, attributes, property=nil)
    attributes = [attributes] unless attributes.is_a? Array
    hashes.each do |hash|
      resource = self.find_or_initialize_by(hash.slice(*attributes))
      resource.attributes = hash
      resource.property = property if property

      resource.save!
    end
  end
end

ActiveRecord::Base.transaction do
  # USERS CAN'T CUSTOMIZE THESE SO USE SEED DATA TO MANAGE THEM THESE RUN EVERY TIME
  unit_names = %W(Gallon LB Case Each Box OZ QT ML Pack Bar Cake Dozen LT LT LT Meters Inches GM KG Keg)
  Unit.find_or_initialize_many(unit_names.map{|name| {name: name}}, :name)

  roles = []
  Role.find_or_initialize_many(Role::ROLE_NAMES.map{|name| {name: name}}, :name)

  gm_role = Role.find_by(name: 'General Manager')

  # Permissions
  permission_subjects = ["User", "Category", "Location", "List", "PurchaseOrder"] 
  permission_actions = ["manage", "create", "read"]

  permissions = [
    {role: gm_role,  action: 'manage', subject_type: 'User' },
    {role: gm_role,  action: 'manage', subject_type: 'Category' },
    {role: gm_role,  action: 'manage', subject_type: 'Location' },
    {role: gm_role,  action: 'manage', subject_type: 'List' },
    {role: gm_role,  action: 'create', subject_type: 'PurchaseOrder' },
  ]

  permissions.each do |p|
    attributes = p.except(:role)
    p[:role].permissions.find_or_initialize_by(attributes).save!
  end


  Report.find_or_initialize_many(Report::ALL_KINDS, :permalink)

  #USERS CAN CUSTOMIZE THESE SO THESE ONLY IF NO DATA IS ALREADY THERE
  hotel1 = Property.first
  hotel2 = Property.last

  unless Property.any?
    properties = [
      {
                :name => "Hotel 1",
        :contact_name => "Shaunak Patel",
      :street_address => "5625 Dillard Drive, Suite 215 B",
            :zip_code => "27518",
                :city => "Cary, NC",
               :phone => "919-854-1234",
      },
      { 
                :name => 'Hotel 2'
      }
    ]
    Property.find_or_initialize_many(properties, :name)
    hotel1 = Property.find_by(name: 'Hotel 1')
    hotel2 = Property.find_by(name: 'Hotel 2')
  end

  Property.current_id = Property.first.id

  unless Department.any?
    department_names = %W(F&B Housekeeping Maintenance)
    Property.current_id = hotel1.id
    Department.find_or_initialize_many(department_names.map{|name| {name: name}}, :name)

    Property.current_id = hotel2.id
    Department.find_or_initialize_many(department_names.map{|name| {name: name}}, :name)
  end

  unless User.any?
    Property.current_id = hotel1.id
    h1_gm_user = User.find_or_initialize_by(email: 'gm_h1@example.com')
    h1_gm_user.current_property_role = gm_role
    h1_gm_user.departments << Department.first
    h1_gm_user.attributes = {name: 'GM User @ H1',  password: 'password'}
    h1_gm_user.skip_confirmation!
    h1_gm_user.save!

    Property.current_id = hotel2.id
    h2_gm_user = User.find_or_initialize_by(email: 'gm_h2@example.com')
    h2_gm_user.current_property_role = gm_role
    h2_gm_user.departments << Department.first
    h2_gm_user.attributes = {name: 'GM User @ H2',  password: 'password'}
    h2_gm_user.skip_confirmation!
    h2_gm_user.save!
    Property.current_id = hotel1.id
  end

  unless Vendor.any?
    vendor_names = ["Guest Supply Sysco", "Koss Supplies LLC.", "Lang Supplies LLC.", "Towne Shipping Co.", "Larson Shipping Co.", "Bode Stuff and Misc Co.", "Crist Supplies LLC.", "Jacobs Stuff and Misc Co.", "Fay Supplies LLC.", "Champlin Supplies LLC.", "Rosenbaum Shipping Co.", "US Foods"]
    Vendor.find_or_initialize_many(vendor_names.map{|name| {name: name}}, :name, hotel1)
  end

  unless Category.any?
    category_names = ["Housekeeping", "Food & Beverage"]
    hotel1_categories = category_names.map{|name| {name: name, property: hotel1}}
    hotel2_categories = category_names.map{|name| {name: name, property: hotel2}}
    Category.find_or_initialize_many(hotel1_categories + hotel2_categories, [:name, :property])

    h1_housekeeping_cat = hotel1.categories.unscoped.find_by(name: 'Housekeeping')
    h1_food_cat = hotel1.categories.unscoped.find_by(name: 'Food & Beverage')
  end

end #of the transaction
