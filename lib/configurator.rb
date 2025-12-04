# frozen_string_literal: true

module MyApplicationKriukov
  class Configurator
    attr_reader :config

    DEFAULT_CONFIG = {
      run_website_parser: 1,
      thread_size: 5,
      run_save_to_file: 1,
      run_save_to_csv: 1,
      run_save_to_json: 0,
      run_save_to_yaml: 0

    }.freeze

    # run_save_to_sqlite: 0,
    # run_save_to_mongodb: 0

    def initialize
      @config = DEFAULT_CONFIG.dup
    end

    def configure(overrides = {})
      overrides.each do |key, value|
        if @config.key?(key)
          @config[key] = value
        else
          warn "[Configurator] Warning: invalid config key '#{key}'"
        end
      end
    end

    def self.available_methods
      DEFAULT_CONFIG.keys
    end
  end
end
