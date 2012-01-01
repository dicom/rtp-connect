# encoding: UTF-8

# This is a simple Ruby script which reads a Mosaiq RTPConnect file
# and manipulates it using a set of predefined, default values.
#
# Author:
# Christoffer Lervåg (chris.lervag [@nospam.com] @gmail.com)


#############
### SETUP ###
#############

# Load the rtp-connect gem:
require 'rtp-connect'
include RTP

# Choose the file to process:
file = '../samples/oncentra_columna_dose.rtp'


################
### SETTINGS ###
################

# COURSE ID:
default_course_id = '1'

# Site name:
default_site_name = 'Columna'

# DELIVERY PATTERN:
default_pattern = 'Daily'

# Dose specification
default_dose_specification = 'Plan'

# TOLERANCE TABLES:
default_site_tolerance_table = '10'
default_field_tolerance_table = '1'


################
### EXECUTION ##
################

# Load a Plan object from the RTP file:
p = Plan.read(file)

# Set course id:
p.course_id = default_course_id

# Plan and prescription site:
p.prescriptions.each do |rx|
  # PRESCRIPTION SITE:
  # Course id is defined for each prescription:
  rx.course_id = default_course_id
  # Set site name:
  rx.rx_site_name = default_site_name
  # Set dose specification:
  rx.dose_spec = default_dose_specification
  # Set delivery pattern:
  rx.pattern = default_pattern
  # SITE SETUP:
  # Set (site setup) tolerance table:
  rx.site_setup.tolerance_table = default_site_tolerance_table
  # Apply the site name here too:
  rx.site_setup.rx_site_name = rx.rx_site_name
  # Treatment fields:
  rx.fields.each do |f|
    # TREATMENT FIELDS:
    # Apply new site name here as well:
    f.rx_site_name = rx.rx_site_name
  end
end

# Write the processed Plan object to a new file:
p.write('processed.rtp')