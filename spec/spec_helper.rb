require File.dirname(__FILE__) + '/../lib/rtp-connect'

RSpec.configure do |config|
  config.mock_with :mocha
end

# Defining constants for the sample RTPConnect files that are used in the specification,
# while suppressing the annoying warnings when these constants are initialized.
module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end

suppress_warnings do
  # Sample RTPConnect files:
  # Files exported from Oncentra and imported with Mosaiq 2.2:
  RTP::RTP_COLUMNA = 'samples/oncentra_columna_dose.rtp'
  RTP::RTP_PROSTATE = 'samples/oncentra_prostate_dose_imrt.rtp'
  RTP::RTP_IMRT = 'samples/oncentra_prostate_nodose_boost.rtp'
  RTP::RTP_TANGMAM = 'samples/oncentra_tangmam_nodose.rtp'
  RTP::RTP_SIEMENS_58 = 'samples/aria_siemens_mlc-58.rtp'
  # File exported from Mosaiq 2.2:
  RTP::RTP_ELECTRON = 'samples/mosaiq_electron_dt.rtp'
  # File created with Mosaiq 2.4:
  RTP::RTP_MOSAIQ_24 = 'samples/mosaiq_2.4.rtp'
  # Other Mosaiq:
  RTP::RTP_SIM = 'samples/simulation_field.rtp'
  # Other:
  RTP::RTP_ATTRIBUTE_COMMA = 'samples/attribute_with_comma.rtp'
  RTP::RTP_ATTRIBUTE_PAIRS_QUOTES = 'samples/attribute_with_pairs_of_quotes.rtp'
  RTP::RTP_ATTRIBUTE_QUOTED_COMMA = 'samples/attribute_with_quoted_comma.rtp'
  # Invalid files:
  RTP::RTP_INVALID_QUOTE = 'samples/invalid_csv_attribute_with_single_quote.rtp'
  # Directory for writing temporary files:
  RTP::TMPDIR = "tmp/"
  RTP::LOGDIR = RTP::TMPDIR + "logs/"
end

# Create a directory for temporary files (and delete the directory if it already exists):
require 'fileutils'
FileUtils.rmtree(RTP::TMPDIR) if File.directory?(RTP::TMPDIR)
FileUtils.mkdir(RTP::TMPDIR)
FileUtils.mkdir(RTP::LOGDIR)