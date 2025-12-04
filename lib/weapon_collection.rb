# lib/weapon_collection.rb
require 'json'
require 'csv'
require 'yaml'
require_relative 'weapon_container'

module MyApplicationKriukov
  class WeaponCollection
    include WeaponContainer
    include Enumerable

    attr_accessor :weapons

    def initialize
      @weapons = []
      LoggerManager.logger.info('WeaponCollection initialized')
      self.class.increment_counter
    end

    def each(&)
      weapons.each(&)
    end

    # ---------------- SAVE METHODS ----------------

    def save_to_file(path)
      File.open(path, 'w') do |file|
        weapons.each { |w| file.puts w.to_s }
      end
      LoggerManager.logger.info("Saved collection to file: #{path}")
    end

    def save_to_json(path)
      data = weapons.map(&:to_h)
      File.write(path, JSON.pretty_generate(data))
      LoggerManager.logger.info("Saved collection to JSON: #{path}")
    end

    def save_to_csv(path)
      CSV.open(path, 'w') do |csv|
        csv << weapons.first.to_h.keys
        weapons.each { |w| csv << w.to_h.values }
      end
      LoggerManager.logger.info("Saved collection to CSV: #{path}")
    end

    def save_to_yml(path)
      Dir.mkdir(path) unless Dir.exist?(path)
      weapons.each_with_index do |w, i|
        File.write("#{path}/weapon_#{i + 1}.yml", w.to_h.to_yaml)
      end
      LoggerManager.logger.info("Saved collection to YAML folder: #{path}")
    end

    def generate_test_weapons(count = 5)
      count.times do
        weapon = Weapon.generate_fake
        add_item(weapon)
      end

      LoggerManager.logger.info("Generated #{count} test weapons")
    end

    def strong_weapons(limit)
      select { |w| w.atk.to_i > limit }
    end

    def names
      map(&:name)
    end

    def rare_only
      select { |w| w.rarity == '★★★★★' }
    end

    def total_attack
      reduce(0) { |sum, w| sum + w.atk.to_i }
    end

    def has_skill?(skill_name)
      any? { |w| w.skill == skill_name }
    end

    def unique_types
      map(&:type).uniq
    end
  end
end
