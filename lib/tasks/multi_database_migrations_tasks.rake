module MultiMigrations
  def self.make_connection(db_name = nil)
    raise "DATABASE is required" unless ENV['DATABASE']
    connection_key = self.identify_configuration
    raise "VALID DATABASE is required" unless connection_key
    ActiveRecord::Base.establish_connection(connection_key)
  end
  
  def self.identify_configuration
    if ActiveRecord::Base.configurations.has_key?("#{ENV['DATABASE']}_#{Rails.env}")
      return "#{ENV['DATABASE']}_#{Rails.env}"
    else
      match = ActiveRecord::Base.configurations.find { |config| config[1]['database'] == ENV['DATABASE'] }
      return match[0] unless match.nil?
    end
  end
end

namespace :db do
  namespace :multi do
    desc "Migrate through the scripts in db/migrate/<dbname>/ Target specific version with VERSION=x. Turn off output with VERBOSE=false."
    task :migrate => :environment do
      MultiMigrations.make_connection(ENV['DATABASE'])
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("db/migrate/#{ENV['DATABASE']}", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:multi:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
    
    namespace :migrate do
      desc  'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x'
      task :redo => [ 'db:multi:rollback', 'db:multi:migrate' ]

     # TODO: Implement db:multi:drop, db:multi:create
     #desc 'Resets your database using your migrations for the current environment'
     #task :reset => ["db:multi:drop", "db:multi:create", "db:multi:migrate"]

      desc 'Runs the "up" for a given migration VERSION.'
      task :up => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        MultiMigrations.make_connection(ENV['DATABASE'])
        ActiveRecord::Migrator.run(:up, "db/migrate/#{ENV['DATABASE']}", version)
        Rake::Task["db:multi:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
      end

      desc 'Runs the "down" for a given migration VERSION.'
      task :down => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        MultiMigrations.make_connection(ENV['DATABASE'])
        ActiveRecord::Migrator.run(:down, "db/migrate/#{ENV['DATABASE']}", version)
        Rake::Task["db:multi:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
      end
    end
    
    desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
    task :rollback => :environment do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      MultiMigrations.make_connection(ENV['DATABASE'])
      ActiveRecord::Migrator.rollback("db/migrate/#{ENV['DATABASE']}", step)
      Rake::Task["db:multi:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    
    namespace :schema do
      desc "Create a db/schema.rb file that can be portably used against any DB supported by AR"
      task :dump => :environment do
        MultiMigrations.make_connection(ENV['DATABASE'])
        require 'active_record/schema_dumper'
        File.open(ENV['SCHEMA'] || "db/schema_#{ENV["DATABASE"]}.rb", "w:utf-8") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end

      desc "Load a schema.rb file into the database"
      task :load => :environment do
        MultiMigrations.make_connection(ENV['DATABASE'])
        file = ENV['SCHEMA'] || "db/schema_#{ENV['DATABASE']}.rb"
        load(file)
      end
    end
    
  end
end
