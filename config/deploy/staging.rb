# allows deployment of custom branch:
# `cap staging deploy -s branch=my_branch`
set :branch, fetch(:branch, 'dev')

role :web, 'metaflop-staging.panter.biz'
role :app, 'metaflop-staging.panter.biz'
