# Multi::Database::Migrations

A plugin to make it easier to host migrations for multiple databases in one rails app.  NOTE: This has been upgraded to work with Rails 3.0.x.

## Installation

Add this line to your application's Gemfile:

    gem 'multi-database-migrations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multi-database-migrations

## CONCEPT

Rather than mixing all the migrations in one folder and relying on the specific migration to define which database it works with, we have separate folders for each database. Supposing you had a normal database--myapp\_development--and a legacy database--legacy\_development--we'd have something like:

    db/migrate
      db/migrate/myapp
      db/migrate/legacy

and each database's migrations sit in the relevant folder.

### USAGE

With the plugin installed we have:

    rails g multi_migration MigrationName DBName ....

which should accept all the options of a normal migration generation, and

    rake db:multi:migrate DATABASE=xxxx

normally we would expect the database name to match rails' conventions, eg:

    rake db:multi:migrate DATABASE=myapp

would look for a database configuration of myapp\_development. But if you specify a full database name, we will look for a configuration with a matching database name.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### CREDIT

* This plugin was originally created by James Stewart - http://jystewart.net/process/
* Converted to Rails 3 by Chris Rohr http://www.nearinfinity.com/blogs/chris_rohr/
* Converted to gem by sinsoku https://github.com/sinsoku/
