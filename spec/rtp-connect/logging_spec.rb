# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe "Logger" do

    it "should be able to log to a file" do
      RTP.logger = Logger.new(LOGDIR + 'logfile1.log')
      RTP.logger.info("test")
      expect(File.open(LOGDIR + 'logfile1.log').readlines.last).to match(/INFO.*test/)
    end

    it "should be able to change the logging level" do
      expect(RTP.logger.level).to eq(Logger::DEBUG)
      RTP.logger.level = Logger::FATAL
      expect(RTP.logger.level).to eq(Logger::FATAL)
    end

    it "should always say RTP (for progname) when used within the RTP module" do
      RTP.logger = Logger.new(LOGDIR + 'logfile2.log')
      RTP.logger.info("test")
      expect(File.open(LOGDIR + 'logfile2.log').readlines.last).to match(/RTP:.*test/)
    end

    it "should use MARK (for progname) if I explicitly tell it to" do
      RTP.logger = Logger.new(LOGDIR + 'logfile3.log')
      RTP.logger.info("MARK") { "test" }
      expect(File.open(LOGDIR + 'logfile3.log').readlines.last).to match(/MARK:.*test/)
    end

    it "should use progname RTP and MARK depending on where it was called" do
      logger = Logger.new(LOGDIR + 'logfile4.log')
      logger.progname = "MARK"
      RTP.logger = logger
      RTP.logger.info("test")
      expect(File.open(LOGDIR + 'logfile4.log').readlines.last).to match(/RTP:.*test/)
      logger.info("test")
      expect(File.open(LOGDIR + 'logfile4.log').readlines.last).to match(/MARK:.*test/)
    end

    it "should be a class of ProxyLogger inside the RTP module and Logger outside" do
      logger = Logger.new(LOGDIR + 'logfile5.log')
      RTP.logger = logger
      expect(RTP.logger.class).to eq(Logging::ClassMethods::ProxyLogger)
      expect(logger.class).to eq(Logger)
    end

    it "should not print messages when a non-verbose mode has been set (Logger::FATAL)" do
      RTP.logger = Logger.new(LOGDIR + 'logfile6.log')
      RTP.logger.level = Logger::FATAL
      RTP.logger.debug("Debugging")
      RTP.logger.info("Information")
      RTP.logger.warn("Warning")
      RTP.logger.error("Errors")
      expect(File.open(LOGDIR + 'logfile6.log').readlines.last.include?('RTP')).to be_false
    end

    it "should print messages when a verbose mode has been set (Logger::DEBUG)" do
      RTP.logger = Logger.new(LOGDIR + 'logfile7.log')
      RTP.logger.level = Logger::DEBUG
      RTP.logger.debug("Debugging")
      RTP.logger.info("Information")
      RTP.logger.warn("Warning")
      RTP.logger.error("Errors")
      expect(File.open(LOGDIR + 'logfile7.log').readlines.last.include?('RTP')).to be_true
    end

  end

end
