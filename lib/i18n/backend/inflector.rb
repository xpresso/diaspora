require 'i18n/exceptions'

module I18n
  module Backend
    module Inflector
      def translate(locale, key, options = {})
        inflection = options.delete(:inflection)
        translated_string = super(locale, key, options)

        unless File.exists?(inflection_file(locale))
          return translated_string
        end

        inflections = YAML.load_file(inflection_file(locale))[locale.to_s]['inflections']
        default = inflections.delete('default')
        inflections = inflections.keys.sort

        inflection ||= default
        if inflection.nil? || inflections.index(inflection).nil?
          raise I18n::MissingTranslationData.new(locale, key, {})
        end

        regex = inflections.map { |i| "#{i}: \"([^\"]+?)\"" }.join(', ')
        inflected_translations = translated_string.match(/^#{regex}$/)
        if inflected_translations.nil?
          return translated_string
        end

        index_of_inflected_translation = inflections.index(inflection) + 1
        if inflected_translations[index_of_inflected_translation].present?
          return inflected_translations[index_of_inflected_translation]
        else
          return translated_string
        end
      end

      def inflection_file(locale)
        File.join(Rails.root, "config", "locales", "inflections", "#{locale}.yml")
      end
    end
  end
end
