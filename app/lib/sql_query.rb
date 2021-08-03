#
# Run a raw SQL query from the app's queries directory. Safely interpolates
# supplied parameters. This uses an independent connection from ActiveRecord.

class SqlQuery
  DB = Sequel.connect(ActiveRecord::Base.connection_config)
  DB.extension :pg_streaming, :pg_array, :pg_json
  Sequel.extension(:pg_array_ops)

  DB.logger = Rails.logger

  Sequel.default_timezone = :utc
  DB << "SET timezone='UTC'"

  QUERY_DIR = Rails.root.join('app/queries')

  # Execute query and return rows as an array
  def self.results(name, **params)
    load(name, **params).results
  end

  # Load a query with interpolations
  def self.load(name, **params)
    path = QUERY_DIR.join("#{name}.sql")
    new(path.read, params)
  rescue Errno::ENOENT
    raise "Query not found `#{name}`: can't read file #{path}"
  end

  class << self
    # Wrap queries in a transaction
    delegate :transaction, to: :db

    # Mark a string as non-escapable pre-interpolation
    delegate :lit, to: :Sequel

    # Results is a dumb method name, but I don't want to break open PRs just yet
    alias run results
  end

  def initialize(sql, **params)
    @dataset = DB[sql, params]
  end

  # Execute query and return rows as an array
  def results
    @dataset.all
  end

  # Get the first row from the results
  def result
    results[0]
  end

  # Return a single field from the first row of the query
  def get(field)
    @dataset.get(field)
  end

  # Called by Sequel when interpolating values. Allows safe interpolation into
  # other queries as a SQL fragment
  #
  # e.g. SqlQuery.run('aggregate_results', results: SqlQuery.load('results'))
  def sql_literal(*)
    @dataset.sql
  end
end
