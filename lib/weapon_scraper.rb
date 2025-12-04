require 'ferrum'
require 'nokogiri'
require 'uri'

module MyApplicationKriukov
  class WeaponScraper
    attr_reader :collection

    def initialize(config, configurator)
      @start_page = config['web_scraping']['start_page']
      @container_selector = config['web_scraping']['container_selector']
      @item_selector = config['web_scraping']['item_selector']
      @logger = LoggerManager.logger
      @browser = Ferrum::Browser.new(timeout: 30)
      @configurator = configurator

      @collection = WeaponCollection.new
    end

    def scrape_all
      @browser.goto(@start_page)
      @browser.network.wait_for_idle

      doc = Nokogiri::HTML(@browser.body)
      container = doc.at_css(@container_selector)
      raise 'Контейнер не знайдено!' if container.nil?

      links = container.css(@item_selector).map { |a| URI.join(@start_page, a['href']).to_s }
      @logger.info("Found #{links.size} weapons")

      links.each { |link| scrape_weapon_page(link) }

      auto_save_collection
    end

    def scrape_weapon_page(url)
      @browser.goto(url)
      @browser.network.wait_for_idle
      doc = Nokogiri::HTML(@browser.body)

      name = doc.at_css('div.char-name-text')&.text&.strip

      tables = doc.css('div.grid.grid-cols-2')
      type = rarity = atk = nil
      second_stat_name = second_stat = nil

      tables.each do |tbl|
        divs = tbl.css('div')
        next if divs.size < 2

        key = divs[0].text.strip
        val = divs[1].text.strip

        case key
        when 'ATK'
          if atk.nil?
            atk = val
          else
            second_stat_name ||= key
            second_stat ||= val
          end
        when 'Type'
          type = val
        when 'Rarity'
          rarity = val
        else
          second_stat_name ||= key
          second_stat ||= val
        end
      end

      description_node = doc.at_css('div.flex.flex-col.self-end.py-2.text-xs.font-normal')
      description = description_node ? description_node.inner_html.gsub('<br>', "\n").strip : nil

      ability_name = doc.at_css('div.flex.pb-1.text-lg.font-bold')&.text&.strip
      ability_desc = doc.at_css('div.text-sm.font-normal')&.text&.strip

      # Створюємо об'єкт Weapon
      weapon = Weapon.new(
        name: name,
        type: type,
        rarity: rarity,
        atk: atk,
        second_stat_name: second_stat_name,
        second_stat: second_stat,
        description: description,
        skill: ability_name,
        skill_description: ability_desc,
        image_path: nil
      )

      @collection.add_item(weapon)
      @logger.info("Added weapon: #{name}")
    rescue StandardError => e
      @logger.error("Error parsing #{url}: #{e}")
    end

    private

    def auto_save_collection
      if @configurator.config[:run_save_to_csv] == 1
        @collection.save_to_csv('output/weapons.csv')
        @logger.info('Collection saved to CSV')
      end

      if @configurator.config[:run_save_to_json] == 1
        @collection.save_to_json('output/weapons.json')
        @logger.info('Collection saved to JSON')
      end

      return unless @configurator.config[:run_save_to_yaml] == 1

      @collection.save_to_yml('output/yaml')
      @logger.info('Collection saved to YAML')
    end
  end
end
