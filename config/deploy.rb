#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

# the file "user" only contains the following line
# set :user, "<username>"
# if your local username is the same as the ssh-user you might not need this
require 'bundler/capistrano'
require 'capistrano-rbenv'

require 'capistrano/ext/multistage'
set :stages, %w(production staging)
set :default_stage, "staging"

default_run_options[:pty] = true # password prompt from git
ssh_options[:forward_agent] = true # use local ssh key

set :application, "metaflop"
set :branch, "master"
set :git_enable_submodules, 1

set :user, "rails"

set :use_sudo, false

set :rbenv_ruby_version, '2.0.0-p247'
set :rbenv_install_dependencies, false

# unicorn wrapper restart
namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "RAILS_ENV=#{rails_env} $HOME/bin/unicorn_wrapper restart"
  end
end

namespace :config do
  task :db do
    upload('db.yml', "#{deploy_to}/current/db.yml")
  end
end

before "deploy:restart", "config:db"
