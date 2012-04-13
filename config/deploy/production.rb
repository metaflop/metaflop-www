set :scm, :git
set :repository,  "git@github.com:greyfont/metaflop-www.git"
set :deploy_via, :remote_cache # don't clone repo each time
set :deploy_to, "/local/metaflop/www/metaflop.greyfont.com"

role :web, "metaflop.greyfont.com"
role :app, "metaflop.greyfont.com"
