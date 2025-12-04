module MyApplicationKriukov
  module WeaponContainer
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
      base.class_eval do
        @objects_created = 0
      end
    end

    module ClassMethods
      def class_info
        "Class: #{name}, Version: 1.0"
      end

      def increment_counter
        @objects_created ||= 0
        @objects_created += 1
      end

      def objects_created
        @objects_created
      end
    end

    module InstanceMethods
      def add_item(item)
        weapons << item
        LoggerManager.logger.info("Added item: #{item.name}")
      end

      def remove_item(item)
        weapons.delete(item)
        LoggerManager.logger.info("Removed item: #{item.name}")
      end

      def delete_items
        weapons.clear
        LoggerManager.logger.info('All items removed')
      end

      def method_missing(name, *args, &)
        if name == :show_all_items
          weapons.each { |w| puts w }
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        name == :show_all_items || super
      end
    end
  end
end
