set :scm, :none
set :repository,  "."
set :deploy_via, :copy
set :deploy_to, "/home/rails/app"

role :web, "metaflop-staging.panter.ch"
role :app, "metaflop-staging.panter.ch"
