lock '~> 3.19.2'

set :application, 'metaflop'
set :repo_url, 'git@github.com:metaflop/metaflop-www.git'
set :branch, 'master'
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, "/home/deploy/#{fetch :application}"

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'system'
append :linked_files, 'config/db.yml'

set :keep_releases, 5

namespace :deploy do
  namespace :assets do
    desc 'Compile assets'
    task :precompile do
      on roles(:web) do
        within release_path do
          execute :rake, "assets:precompile RACK_ENV=production"
        end
      end
    end
  end
end

before 'deploy:restart', 'deploy:assets:precompile'
