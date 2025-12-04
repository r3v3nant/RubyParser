require 'yaml'
require 'erb'
require 'json'

def load_libs
  Dir[File.join(__dir__, '../lib', '*.rb')].each { |file| require_relative file }
end

load_libs

module MyApplicationKriukov
  class ConfigLoader
    class << self
      attr_reader :config_data

      def config(main_file:, directory:)
        @config_data = {}

        load_default_config(main_file)
        load_config(directory)

        yield @config_data if block_given?
        @config_data
      end

      def pretty_print_config_data
        puts JSON.pretty_generate(@config_data)
      end

      private

      def load_default_config(path)
        erb = ERB.new(File.read(path)).result
        data = YAML.safe_load(erb)

        @config_data.merge!(data)

        # зберігаємо директорію YAML
        @yaml_dir = data.dig('default', 'yaml_dir')
      end

      def load_config(_dir = nil)
        dir = @yaml_dir || 'config' # підстраховка

        Dir.glob(File.join(dir, '*.yml')).each do |file|
          next if file.include?('default_config')

          erb = ERB.new(File.read(file)).result
          data = YAML.safe_load(erb)
          @config_data.merge!(data)
        end
      end
    end
  end
end
