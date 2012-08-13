require 'json'
require 'typhoeus'
require 'base64'
require 'mime/types'
require 'logger'

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

module Soca
  VERSION = '0.3.3'

  class << self
    attr_accessor :debug
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger ||= LOGGER if defined?(LOGGER)
    if !@logger
      @logger           = Logger.new(STDOUT)
      @logger.level     = Logger::ERROR
      @logger.formatter = Proc.new {|s, t, n, msg| "#{msg}\n"}
      @logger
    end
    @logger
  end
end

require 'soca/pusher'
require 'soca/cli'
require 'soca/plugin'
