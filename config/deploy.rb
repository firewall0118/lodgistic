# Capistrano Configuration
# see commands available with cap -T
# Look in config/deploy/production.rb and config/deploy/staging.rb to set the server specific configs (IP address)

require 'bundler/capistrano'
require 'capistrano/ext/multistage'

load 'config/recipes/base'
load 'config/recipes/shared'
load 'config/recipes/nginx'
load 'config/recipes/unicorn'
load 'config/recipes/postgresql'
load 'config/recipes/nodejs'
load 'config/recipes/rbenv'
load 'config/recipes/memcached'
load 'config/recipes/dragonfly'
# load 'config/recipes/foreman'
# load 'config/recipes/elasticsearch'
# load 'config/recipes/paperclip'
# load 'config/recipes/redis'
# load 'config/recipes/check'
load 'config/recipes/swapfile'

set :user, 'deployer'
set :application, 'lodgistics'

# Don't name your stage "stage", as this is a reserved word
set :stages, %w(production staging)
set :default_stage, 'staging'

set :deploy_to, "/home/#{user}/www/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, 'git'
set :repository, 'git@github.com:smashingboxes/lodgistics.git'
set :branch, 'master'
set :remote, 'origin'
# set :use_ssl, true # uncomment if you want to use https

set :default_environment, {'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"}
set :maintenance_template_path, File.expand_path('../recipes/templates/maintenance.html.erb', __FILE__)

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after 'deploy', 'deploy:cleanup'
after 'deploy', 'deploy:migrate'
# after 'deploy', 'deploy:seed'

# hook to automatically push code before every deploy
before 'deploy:update_code' do
  puts "Pushing #{branch} code to git repository ..."
  system "git push -u #{remote} #{branch}"
  abort unless $?.success?
end
