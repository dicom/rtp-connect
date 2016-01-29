# encoding: UTF-8

# This is a simple Ruby script which reads a Mosaiq RTPConnect file
# and modifies parameters like gantry angle, collimator angle, MLC positions,
# jaw positions and/or monitor units for QA purposes.
#
# Author:
# Christoffer Lervåg (chris.lervag [@nospam.com] @gmail.com)


#############
#### SETUP ####
#############

# Load the rtp-connect gem:
require 'rtp-connect'
include RTP

# Choose the file to process:
file = 'original.rtp'

################
## Modification values ##
################

# To avoid modifying one or more of the parameters below, set its offset value
# as 0.0 and its gain value as 1.0.

# Note that for leaf bank and jaw positions, a (positive) offset value increases the
# field gap on both sides, meaning that the total field gap in that direction increases
# by twice the offset used. A gain modification similarly affects both sides, but in
# this case, the total gap opening will be equal to the gain value.

# Note that for monitor units, the modification is done on the field mu parameter. which
# means any change will be evenly distributed on its set of control points. This assumes
# mu_convention = 1. It will probably not work in the case of a different mu convention,
# and for such files, monitor units should not be changed (offset 0, gain 1).

# Monitor units:
mu_offset = 1.0
mu_gain = 1.0
# Gantry angle:
gantry_angle_offset = 1.0
gantry_angle_gain = 1.0
# Collimator angle:
collimator_angle_offset = 1.0
collimator_angle_gain = 1.0
# Collimator positions:
collimator_x_offset = 0.1
collimator_x_gain = 1.0
collimator_y_offset = 0.1
collimator_y_gain = 1.0
# Leaf positions:
mlc_offset = 0.1
mlc_gain = 1.0

################
## Convenience methods ##
################

def modify_non_empty(parameter, offset, gain)
  if parameter.empty?
    parameter
  else
    (gain * parameter.to_f + offset).round(2).to_s
  end
end

def modify_non_zero(parameter, offset, gain)
  if parameter.to_f == 0.0
    parameter
  else
    (gain * parameter.to_f + offset).round(6).to_s
  end
end

def modify_mu(obj, offset, gain)
  obj.field_monitor_units = modify_non_zero(obj.field_monitor_units, offset, gain)
end

def modify_gantry_angle(obj, offset, gain)
  obj.gantry_angle = modify_non_empty(obj.gantry_angle, offset, gain)
end

def modify_collimator_angle(obj, offset, gain)
  obj.collimator_angle = modify_non_empty(obj.collimator_angle, offset, gain)
end

def modify_collimator_x(obj, offset, gain)
  obj.collimator_x1 = modify_non_empty(obj.collimator_x1, -offset, gain)
  obj.collimator_x2 = modify_non_empty(obj.collimator_x2, offset, gain)
end

def modify_collimator_y(obj, offset, gain)
  obj.collimator_y1 = modify_non_empty(obj.collimator_y1, -offset, gain)
  obj.collimator_y2 = modify_non_empty(obj.collimator_y2, offset, gain)
end

def modify_leaves(cp, offset, gain)
  cp.mlc_lp_a = cp.mlc_lp_a.collect {|pos| modify_non_empty(pos, -offset, gain)}
  cp.mlc_lp_b = cp.mlc_lp_b.collect {|pos| modify_non_empty(pos, offset, gain)}
end

################
### EXECUTION ###
################

# Load a Plan object from the RTP file:
p = Plan.read(file)

# Iterate prescriptions:
p.prescriptions.each do |rx|
  # Iterate treatment fields:
  rx.fields.each do |f|
    modify_mu(f, mu_offset, mu_gain)
    modify_gantry_angle(f, gantry_angle_offset, gantry_angle_gain)
    modify_collimator_angle(f, collimator_angle_offset, collimator_angle_gain)
    modify_collimator_x(f, collimator_x_offset, collimator_x_gain)
    modify_collimator_y(f, collimator_y_offset, collimator_y_gain)
    # Iterate control points:
    f.control_points.each do |cp|
      modify_gantry_angle(cp, gantry_angle_offset, gantry_angle_gain)
      modify_collimator_angle(cp, collimator_angle_offset, collimator_angle_gain)
      modify_collimator_x(cp, collimator_x_offset, collimator_x_gain)
      modify_collimator_y(cp, collimator_y_offset, collimator_y_gain)
      modify_leaves(cp, mlc_offset, mlc_gain)
    end
  end
end

# Write the modified RTP object to a new file (with compatibility specified as Mosaiq 2.6):
p.write('modified.rtp', version: 2.6)