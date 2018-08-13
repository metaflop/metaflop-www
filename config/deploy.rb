lock '3.11.0'

set :application, 'metaflop'
set :repo_url, 'git@github.com:metaflop/metaflop-www.git'

namespace :deploy do
  namespace :assets do
    desc 'Compile assets'
    task :precompile do
      on roles(:app), in: :sequence do
        with rack_env: fetch(:rails_env) do
          within release_path do
            execute :ls, '-l'
            execute :ls, '-l config'
            execute :rake, 'assets:precompile'
          end
        end
      end
    end
  end

  after :updated, 'assets:precompile'
end
