require_relative 'lib/config_loader'

module MyApplicationKriukov
  class Main
    def self.run
      config = ConfigLoader.config(
        main_file: 'config/default_config.yml',
        directory: 'config/yaml_config'
      )

      configurator = MyApplicationKriukov::Configurator.new
      configurator.configure(
        run_website_parser: 2,
        thread_size: 10,
        run_save_to_file: 0,
        run_save_to_csv: 0,
        run_save_to_json: 0,
        run_save_to_yaml: 0,
        run_save_to_sqlite: 0,
        run_save_to_mongodb: 1
      )

      #
      LoggerManager.setup(config)
      if configurator.config[:run_save_to_csv] == 1
        scraper = WeaponScraper.new(config, configurator)

        scraper.scrape_all

      elsif configurator.config[:run_website_parser] == 2
        scraper = WeaponScraper.new(config, configurator)

        scraper.scrape_all_thread
      end

      puts 'Program has finished'
    end
  end
end

MyApplicationKriukov::Main.run
