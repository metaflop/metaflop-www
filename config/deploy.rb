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
load './config/user'

require 'capistrano/ext/multistage'
set :stages, %w(production staging)
set :default_stage, "staging"

default_run_options[:pty] = true # password prompt from git
ssh_options[:forward_agent] = true # use local ssh key

set :application, "metaflop"
set :scm, :git
set :repository,  "git@github.com:greyfont/metaflop.git"
set :branch, "master"
set :deploy_via, :remote_cache # don't clone repo each time
set :git_enable_submodules, 1

set :use_sudo, false

# passenger mod_rails restart
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
