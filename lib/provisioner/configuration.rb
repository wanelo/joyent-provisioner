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
      templates[name].merge(global)
    end

    def all
      templates.map { |k, v| {k => v.merge(global)} }
    end

  end
end
