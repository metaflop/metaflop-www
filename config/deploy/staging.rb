set :scm, :none
set :repository,  "."
set :deploy_via, :copy
set :deploy_to, "/local/metaflop/www/test.metaflop.greyfont.com"

role :web, "test.metaflop.greyfont.com"
role :app, "test.metaflop.greyfont.com"
