module Dotenv
  class Configuration
    def self.string(name, options = {})
      define_accessor(name, options) { |value| value }
    end

    def self.integer(name, options = {})
      define_accessor(name, options) { |value| Integer(value) if value }
    end

    BOOLEANS = {
      nil => nil, '' => nil,
      '0' => false, 'false' => false,
      '1' => true, 'true' => true
    }

    def self.boolean(name, options = {})
      options = {:suffix => "?"}.merge(options)
      define_accessor(name, options) do |value|
        BOOLEANS.fetch(value) do
          raise ArgumentError, "invalid value for boolean: #{value.inspect}"
        end
      end
    end

    # Internal: Module that the accessors get defined on
    def self.accessors
      @accessors ||= Module.new
    end

    # Internal: Helper method for defining a new accessor
    #
    # name - the name of the config variable.
    # options[:suffix] - the suffix that gets append to the method name
    def self.define_accessor(name, options = {}, &block)
      accessors.send :define_method, "#{name}#{options[:suffix]}" do
        block.call(variable(name, options[:default])).tap do |value|
          raise ArgumentError, "#{name} is required" if options[:required] && value.nil?
        end
      end
    end

    # The source for environment variables. Override in subclass to customize.
    def env
      ENV
    end

    # Fetch the variable from the environment. Override in sublass to customize.
    #
    # name - the name of an environment variable.
    # default - the default value if the variable is not defined.
    def variable(name, default = nil)
      env.fetch(name.to_s.upcase) { default }
    end

    # Internal: Include accessors into subclass when inheriting this class.
    def self.inherited(subclass)
      subclass.send :include, subclass.accessors
    end
  end
end
