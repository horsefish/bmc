require 'json'
require 'puppet'
require 'yaml'

module Idrac
  class Config
    CONFIG_ADMIN_USERNAME = :admin_username
    CONFIG_ADMIN_PASSWORD = :admin_password
    CONFIG_CONNECTION_TIMEOUT = :connection_timeout
    CONFIG_CONNECTION_OPEN_TIMEOUT = :connection_open_timeout
    CONFIG_IDRAC_BASE_URL = :idrac_base_url
    def self.configure
      @config ||= read_config
      yield @config[CONFIG_IDRAC_BASE_URL], @config
    end

    def self.file_path
      @config_file_path ||= File.expand_path(File.join(Puppet.settings[:confdir], '/idrac_rest.conf'))
    end

    def self.reset
      @config = nil
      @config_file_path = nil
    end

    def self.read_config
      begin
        Puppet::debug("Parsing configuration file #{file_path}")
        # each loop used to convert hash keys from String to Symbol; each doesn't return the modified hash ... ugly, I know
        config = Hash.new
        YAML.load_file(file_path).each{ |key, value| config[key.intern] = value}
      rescue => e
        raise Puppet::ParseError, "Could not parse YAML configuration file '#{file_path}': #{e}"
      end

      if config[CONFIG_ADMIN_USERNAME].nil?
        raise Puppet::ParseError, "Config file #{file_path} must contain a value for key '#{CONFIG_ADMIN_USERNAME}'."
      end
      if config[CONFIG_ADMIN_PASSWORD].nil?
        raise Puppet::ParseError, "Config file #{file_path} must contain a value for key '#{CONFIG_ADMIN_PASSWORD}'."
      end

      {
        CONFIG_ADMIN_USERNAME          => config[CONFIG_ADMIN_USERNAME],
        CONFIG_ADMIN_PASSWORD          => config[CONFIG_ADMIN_PASSWORD],
        CONFIG_CONNECTION_TIMEOUT      => Integer(config.fetch(CONFIG_CONNECTION_TIMEOUT, 10)),
        CONFIG_CONNECTION_OPEN_TIMEOUT => Integer(config.fetch(CONFIG_CONNECTION_OPEN_TIMEOUT, 10)),
        CONFIG_IDRAC_BASE_URL          => config[CONFIG_IDRAC_BASE_URL],
      }
    end
  end
end
