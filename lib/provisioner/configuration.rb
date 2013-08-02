require 'yaml'
require 'ostruct'

module Provisioner
  class Configuration < OpenStruct

    class << self
      def from_path(path)
        self.new(YAML.load_file(path))
      end
    end

    def for_template(name)
      validate_template(name)

      templates[name].merge(global)
    end

    def all
      templates.map { |k, v| {k => v.merge(global)} }
    end

    private

    def validate_template(name)
      error_message = "Can't find configuration for template '#{name}'\nAvailable templates: #{template_names}\n\n"
      Provisioner::Exit.with_message(error_message) unless templates[name]
    end

    def template_names
      return '' unless templates.keys
      templates.keys.join(', ')
    end

  end
end
