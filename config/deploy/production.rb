set :scm, :git
set :repository,  "git@github.com:greyfont/metaflop-www.git"
set :deploy_via, :remote_cache # don't clone repo each time
set :deploy_to, "/home/rails/app"

role :web, "metaflop-production.panter.ch"
role :app, "metaflop-production.panter.ch"
