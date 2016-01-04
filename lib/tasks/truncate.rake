require 'database_cleaner'     
namespace :db do               
  desc "Truncate all tables"   
  task :truncate => :environment do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end
