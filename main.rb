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
        run_website_parser: 1,
        run_save_to_csv: 1,
        run_save_to_json: 1,
        run_save_to_yaml: 0
      )

      #
      if configurator.config[:run_save_to_csv] == 1
        LoggerManager.setup(config)
        scraper = WeaponScraper.new(config, configurator)

        scraper.scrape_all

        # weapons_collection = scraper.collection
      end

      puts 'Program has finished'
    end
  end
end

MyApplicationKriukov::Main.run
