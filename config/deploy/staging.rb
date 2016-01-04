server '192.241.149.120', :web, :app, :queue, :memcache, :db, primary: true
set :rails_env, 'staging'
