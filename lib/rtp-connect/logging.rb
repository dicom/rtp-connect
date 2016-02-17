module RTP

  # This module handles logging functionality.
  #
  # Logging functionality uses the Standard library's Logger class.
  # To properly handle progname, which inside the RTP module is simply
  # "RTP", in all cases, we use an implementation with a proxy class.
  #
  # @note For more information, please read the Standard library Logger documentation.
  #
  # @example Various logger use cases:
  #   require 'rtp-connect'
  #   include RTP
  #
  #   # Logging to STDOUT with DEBUG level:
  #   RTP.logger = Logger.new(STDOUT)
  #   RTP.logger.level = Logger::DEBUG
  #
  #   # Logging to a file:
  #   RTP.logger = Logger.new('my_logfile.log')
  #
  #   # Combine an external logger with RTP:
  #   logger = Logger.new(STDOUT)
  #   logger.progname = "MY_APP"
  #   RTP.logger = logger
  #   # Now you can call the logger in the following ways:
  #   RTP.logger.info "Message"               # => "RTP: Message"
  #   RTP.logger.info("MY_MODULE) {"Message"} # => "MY_MODULE: Message"
  #   logger.info "Message"                     # => "MY_APP: Message"
  #
  module Logging

    require 'logger'

    # Inclusion hook to make the ClassMethods available to whatever
    # includes the Logging module, i.e. the RTP module.
    #
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods which the Logging module is extended with.
    #
    module ClassMethods

      # We use our own ProxyLogger to achieve the features wanted for RTP logging,
      # e.g. using RTP as progname for messages logged within the RTP module
      # (for both the Standard logger as well as the Rails logger), while still allowing
      # a custom progname to be used when the logger is called outside the RTP module.
      #
      class ProxyLogger

        # Creating the ProxyLogger instance.
        #
        # @param [Logger] target a logger instance (e.g. Standard Logger or ActiveSupport::BufferedLogger)
        #
        def initialize(target)
          @target = target
        end

        # Catches missing methods.
        #
        # In our case, the methods of interest are the typical logger methods,
        # i.e. log, info, fatal, error, debug, where the arguments/block are
        # redirected to the logger in a specific way so that our stated logger
        # features are achieved (this behaviour depends on the logger
        # (Rails vs Standard) and in the case of Standard logger,
        # whether or not a block is given).
        #
        # @example Inside the RTP module or an external class with 'include RTP::Logging':
        #   logger.info "message"
        #
        # @example Calling from outside the RTP module:
        #   RTP.logger.info "message"
        #
        def method_missing(method_name, *args, &block)
          if method_name.to_s =~ /(log|debug|info|warn|error|fatal)/
            # Rails uses it's own buffered logger which does not
            # work with progname + block as the standard logger does:
            if defined?(Rails)
              @target.send(method_name, "RTP: #{args.first}")
            elsif block_given?
              @target.send(method_name, *args) { yield }
            else
              @target.send(method_name, "RTP") { args.first }
            end
          else
            @target.send(method_name, *args, &block)
          end
        end

      end

      # The logger class variable (must be initialized
      # before it is referenced by the object setter).
      #
      @@logger = nil

      # The logger object getter.
      #
      # If a logger instance is not pre-defined, it sets up a Standard
      # logger or (if in a Rails environment) the Rails logger.
      #
      # @example Inside the RTP module (or a class with 'include RTP::Logging'):
      #   logger # => Logger instance
      #
      # @example Accessing from outside the RTP module:
      #   RTP.logger # => Logger instance
      #
      # @return [ProxyLogger] the logger class variable
      #
      def logger
        @@logger ||= lambda {
          if defined?(Rails)
            ProxyLogger.new(Rails.logger)
          else
            l = Logger.new(STDOUT)
            l.level = Logger::INFO
            ProxyLogger.new(l)
          end
        }.call
      end

      # The logger object setter.
      # This method is used to replace the default logger instance with
      # a custom logger of your own.
      #
      # @param [Logger] l a logger instance
      #
      # @example Multiple log files
      #   # Create a logger which ages logfile once it reaches a certain size,
      #   # leaving 10 "old log files" with each file being about 1,024,000 bytes:
      #   RTP.logger = Logger.new('foo.log', 10, 1024000)
      #
      def logger=(l)
        @@logger = ProxyLogger.new(l)
      end

    end

    # A logger object getter.
    # Forwards the call to the logger class method of the Logging module.
    #
    # @return [ProxyLogger] the logger class variable
    #
    def logger
      self.class.logger
    end

  end

  # Include the Logging module so we can use RTP.logger.
  include Logging

end
