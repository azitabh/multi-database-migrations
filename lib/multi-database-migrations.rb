require "multi-database-migrations/version"

module Multi
  module Database
    module Migrations
      class Railtie < Rails::Railtie
        rake_tasks do
          load "multi-database-migrations/tasks/multi_database_migrations_tasks.rake"
        end
      end
    end
  end
end
