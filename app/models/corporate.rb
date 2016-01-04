class Corporate < ActiveRecord::Base
  
  has_many :users
  has_many :connections
  has_many :properties, ->{ where('corporate_connections.state = ?', :active) }, through: :connections

end
