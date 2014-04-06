# allows deployment of custom branch:
# `cap staging deploy -s branch=my_branch`
set :branch, fetch(:branch, "dev")

role :web, "metaflop-staging.panter.ch"
role :app, "metaflop-staging.panter.ch"
