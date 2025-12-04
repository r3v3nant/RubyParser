require 'logger'

module MyApplicationKriukov
  class LoggerManager
    class << self
      attr_reader :logger

      def setup(config)
        log_dir = config['logging']['directory']
        Dir.mkdir(log_dir) unless Dir.exist?(log_dir)

        main_file = File.join(log_dir, config['logging']['files']['application_log'])
        @logger = Logger.new(main_file)

        @logger.level = case config['logging']['level']
                        when 'DEBUG' then Logger::DEBUG
                        when 'INFO'  then Logger::INFO
                        when 'WARN'  then Logger::WARN
                        else Logger::ERROR
                        end
      end

      def log_processed(name)
        @logger.info("Processed: #{name}")
      end

      def log_error(err)
        @logger.error(err)
      end
    end
  end
end
