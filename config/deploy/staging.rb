# allows deployment of custom branch:
# `cap staging deploy -s branch=my_branch`
set :branch, fetch(:branch, 'dev')

server 'metaflop-staging.panter.biz', :app, :web, :db, primary: true
