require 'faker'

module MyApplicationKriukov
  class Weapon
    include Comparable

    ATTRIBUTES = %i[
      name
      type
      rarity
      atk
      second_stat_name
      second_stat
      description
      skill
      skill_description
      image_path
    ].freeze

    attr_accessor(*ATTRIBUTES)

    def initialize(params = {})
      LoggerManager.log_processed('Weapon initialization')

      # Встановлюємо значення за замовчуванням
      ATTRIBUTES.each do |attr|
        send("#{attr}=", params[attr] || params[attr.to_s] || default_value(attr))
      end

      # Блок для налаштування
      yield self if block_given?
    rescue StandardError => e
      LoggerManager.log_error("Weapon#initialize error: #{e}")
    end

    def to_s
      ATTRIBUTES.map { |a| "#{a}: #{send(a)}" }.join("\n")
    end

    alias info to_s

    def to_h
      ATTRIBUTES.to_h { |a| [a, send(a)] }
    end

    def inspect
      "#<Weapon #{to_h}>"
    end

    # ---------------------------------------
    # Можливість редагування через блок
    # ---------------------------------------

    def update
      yield self if block_given?
    rescue StandardError => e
      LoggerManager.log_error("Weapon#update error: #{e}")
    end

    # ---------------------------------------
    # Comparable (порівнюємо за atk)
    # ---------------------------------------

    def <=>(other)
      return nil unless other.is_a?(Weapon)

      atk.to_i <=> other.atk.to_i
    end

    # ---------------------------------------
    # Генерація фейкових даних
    # ---------------------------------------

    def self.generate_fake
      new(
        name: Faker::Games::ElderScrolls.weapon,
        type: Faker::Games::Zelda.item,
        rarity: ['★', '★★', '★★★', '★★★★', '★★★★★'].sample,
        atk: rand(20..700).to_s,
        second_stat_name: 'ATK',
        second_stat: "#{rand(1..50)}%",
        description: Faker::Lorem.paragraph,
        skill: Faker::Games::LeagueOfLegends.summoner_spell,
        skill_description: Faker::Lorem.sentence,
        image_path: 'images/fake_weapon.png'
      )
    end

    private

    def default_value(attr)
      case attr
      when :image_path
        'images/default.png'
      else
        nil
      end
    end
  end
end
