# lib/database_connector.rb
require 'sqlite3'
require 'mongo'

module MyApplicationKriukov
  class DatabaseConnector
    attr_reader :db, :config

    def initialize(config)
      @config = config['database_config']
      @logger = LoggerManager.logger
      @db = nil
    end

    def connect_to_database
      case @config['database_type']&.downcase
      when 'sqlite'
        connect_to_sqlite
      when 'mongodb'
        connect_to_mongodb
      else
        raise "Unsupported database type: #{@config['database_type']}"
      end
    rescue StandardError => e
      @logger.error("DB connection error: #{e}")
      raise e
    end

    def close_connection
      return if @db.nil?

      if @db.is_a?(SQLite3::Database)
        @db.close
        @logger.info('SQLite connection closed')
      elsif @db.is_a?(Mongo::Client)
        @db.close
        @logger.info('MongoDB connection closed')
      end

      @db = nil
    end

    private

    def connect_to_sqlite
      sqlite_cfg = @config['sqlite_database']
      db_path = sqlite_cfg['db_file']

      raise 'SQLite DB file not specified!' unless db_path

      @db = SQLite3::Database.new(db_path)
      @db.busy_timeout(sqlite_cfg['timeout']) if sqlite_cfg['timeout']

      @logger.info("Connected to SQLite database at #{db_path}")
      @db
    rescue StandardError => e
      @logger.error("SQLite connection error: #{e}")
      raise e
    end

    def connect_to_mongodb
      mongo_cfg = @config['mongodb_database']

      uri = mongo_cfg['uri']
      db_name = mongo_cfg['db_name']

      raise 'MongoDB URI not specified!' unless uri
      raise 'MongoDB database name not specified!' unless db_name

      @db = Mongo::Client.new(uri, database: db_name)

      @logger.info("Connected to MongoDB at #{uri}, DB: #{db_name}")
      @db
    rescue StandardError => e
      @logger.error("MongoDB connection error: #{e}")
      raise e
    end
  end
end
