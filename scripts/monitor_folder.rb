# encoding: UTF-8

# This is a Ruby script which reads Mosaiq RTPConnect files from a folder
# and manipulates them using a set of predefined, default values. The processed
# files (whether manipulated or not) are saved in the same folder,
# but with a separate file name (prefix).
#
# For Windows users:
# If for some reason you don't want to install Ruby on the computer that is
# going to run the script, the script can be converted to an executable by
# using the gem ocra. Convert the script by typing:
#   ocra script.rb
#    => script.exe
#
# Author:
# Christoffer Lervåg (chris.lervag [@nospam.com] @gmail.com)


#############
### SETUP ###
#############

# Load the rtp-connect gem:
require 'rtp-connect'
# Include the RTP logging module for any messages:
include RTP::Logging

# The folder to scan for files (must end with a delimiter):
path = '//mosaiq/MOSAIQ_APP/RTP/'

# The folder to write files (same folder in our case):
destination = path


################
### SETTINGS ###
################

# COURSE ID:
default_course_id = '1'

# DELIVERY PATTERN:
default_pattern = 'Daily'

# DOSE SPECIFICATION:
default_dose_specification = 'Plan'

# TOLERANCE TABLES:
default_site_tolerance_table = '10'
default_field_tolerance_table = '1'

# PORTFILM PARAMETERS:
default_portfilm_mu_treat = '5'
default_portfilm_coeff_treat = '1.0'


################
### EXECUTION ##
################

# Set the delay between each iteration of the loop (value in seconds):
interval = 60

logger.info("Monitoring the following directory:\n#{path}")
logger.info("Refresh interval has been set to: #{interval} seconds\n")

# The following loop can not be run if Ocra is executing the script to build the executable:
run = true
run = false if defined?(Ocra)

# Run the RTP processing code in a continuous loop:
while run do

  # Get all the files starting with 'DCM' in the specified folder:
  files = Dir.glob(path + "DCM*")
  # To be sure we don't read files that are in the process of being written, wait a short while:
  sleep(1)

  # Iterate files:
  files.each do |file|

    # Load a Plan object from the RTP file:
    begin
      p = RTP::Plan.read(file)
      
      # Set course id:
      p.course_id = default_course_id

      # Plan and prescription site:
      p.prescriptions.each do |rx|
        # PRESCRIPTION SITE:
          # Course id is defined for each prescription:
        rx.course_id = default_course_id
        # Set dose specification:
        rx.dose_spec = default_dose_specification
        # Set delivery pattern:
        rx.pattern = default_pattern
        # SITE SETUP:
        # Set (site setup) tolerance table:
        rx.site_setup.tolerance_table = default_site_tolerance_table
        rx.fields.each do |f|
          # TREATMENT FIELDS:
          # Set default portfilm values:
          f.portfilm_mu_treat = default_portfilm_mu_treat
          f.portfilm_coeff_treat = default_portfilm_coeff_treat
          # Set (field) tolerance table:
          f.tolerance_table = default_field_tolerance_table
        end
      end
      # Write the manipulated Plan object back to file:
      p.write(file)
      logger.info("File processed and saved:  #{File.basename(file)}")
    rescue
      # Do nothing in particular, just print a warning.
      logger.warn("Processing this file failed unexpectedly:  #{File.basename(file)}")
    end

    # We are finished with this file. Rename it. This may fail if another application has
    # locked the file. In this case, the file is left alone with its original file name.
    begin
      File.rename(file, destination + 'F' + File.basename(file))
    rescue
      # Do nothing in particular, just print a warning.
      logger.warn("Did not get access to change this file's name:  #{File.basename(file)}")
    end

  end

  # All files have been processed. Sleep for the desired interval:
  sleep(interval)

end