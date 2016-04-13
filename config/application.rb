$LOAD_PATH.unshift(File.dirname(__FILE__))
%w(models validators api).each do |load_path|
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app', load_path))
end

require 'boot'
Bundler.require :default, ENV['RACK_ENV']

# Main application module
module LearningRegistry
  def self.env
    ENV['RACK_ENV']
  end

  def self.connect
    config = StandaloneMigrations::Configurator.new.config_for(env)
    ActiveRecord::Base.establish_connection(config)
  end
end

ActiveRecord::Base.raise_in_transactional_callbacks = true

LearningRegistry.connect

require 'paper_trail/frameworks/active_record'
require 'base'
