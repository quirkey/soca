require 'json'
require 'jim'
require 'typhoeus'
require 'base64'
require 'mime/types'

module Soca
  VERSION = '0.0.1'

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

require 'soca/push'
require 'soca/cli'