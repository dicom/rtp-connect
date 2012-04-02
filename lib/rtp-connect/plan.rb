#    Copyright 2011 Christoffer Lervag
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
module RTP

  # The Plan class is the highest level of objects in the RTPConnect hierarchy,
  # and the one the user will interact with to read, modify and write files.
  #
  # === Relations
  #
  # * Parent: none
  # * Children: Prescription, DoseTracking
  #
  class Plan < Record
    include Logging

    # The Record which this instance belongs to (nil by definition)
    attr_reader :parent
    # An array of Prescription records (if any) that belongs to this Plan.
    attr_reader :prescriptions
    # An array of DoseTracking records (if any) that belongs to this Plan.
    attr_reader :dose_trackings
    attr_reader :patient_id
    attr_reader :patient_last_name
    attr_reader :patient_first_name
    attr_reader :patient_middle_initial
    attr_reader :plan_id
    attr_reader :plan_date
    attr_reader :plan_time
    attr_reader :course_id
    attr_reader :diagnosis
    attr_reader :md_last_name
    attr_reader :md_first_name
    attr_reader :md_middle_initial
    attr_reader :md_approve_last_name
    attr_reader :md_approve_first_name
    attr_reader :md_approve_middle_initial
    attr_reader :phy_approve_last_name
    attr_reader :phy_approve_first_name
    attr_reader :phy_approve_middle_initial
    attr_reader :author_last_name
    attr_reader :author_first_name
    attr_reader :author_middle_initial
    attr_reader :rtp_mfg
    attr_reader :rtp_model
    attr_reader :rtp_version
    attr_reader :rtp_if_protocol
    attr_reader :rtp_if_version

    # Creates a new Plan by loading a plan definition string (i.e. a single line).
    #
    # === Notes
    #
    # * This method does not perform crc verification on the given string.
    # * If such verification is desired, use methods ::parse or ::read instead.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- A string containing a plan definition record.
    #
    def self.load(string)
      raise ArgumentError, "Invalid argument 'string'. Expected String, got #{string.class}." unless string.is_a?(String)
      # Get the quote-less values:
      values = string.values
      raise ArgumentError, "Invalid argument 'string': Expected exactly 28 elements, got #{values.length}." unless values.length == 28
      rtp = self.new
      # Assign the values to attributes:
      rtp.keyword = values[0]
      rtp.patient_id = values[1]
      rtp.patient_last_name = values[2]
      rtp.patient_first_name = values[3]
      rtp.patient_middle_initial = values[4]
      rtp.plan_id = values[5]
      rtp.plan_date = values[6]
      rtp.plan_time = values[7]
      rtp.course_id = values[8]
      rtp.diagnosis = values[9]
      rtp.md_last_name = values[10]
      rtp.md_first_name = values[11]
      rtp.md_middle_initial = values[12]
      rtp.md_approve_last_name = values[13]
      rtp.md_approve_first_name = values[14]
      rtp.md_approve_middle_initial = values[15]
      rtp.phy_approve_last_name = values[16]
      rtp.phy_approve_first_name = values[17]
      rtp.phy_approve_middle_initial = values[18]
      rtp.author_last_name = values[19]
      rtp.author_first_name = values[20]
      rtp.author_middle_initial = values[21]
      rtp.rtp_mfg = values[22]
      rtp.rtp_model = values[23]
      rtp.rtp_version = values[24]
      rtp.rtp_if_protocol = values[25]
      rtp.rtp_if_version = values[26]
      rtp.crc = values[27]
      return rtp
    end

    # Creates an RTP::Plan instance by parsing a RTPConnect string
    # (i.e. multiple lines, containing multiple definitions).
    #
    # === Parameters
    #
    # * <tt>string</tt> -- An RTPConnect ascii string.
    #
    def self.parse(string)
      raise ArgumentError, "Invalid argument 'string'. Expected String, got #{string.class}." unless string.is_a?(String)
      raise ArgumentError, "Invalid argument 'string': String too short to contain valid RTP data (length: #{string.length})." if string.length < 10
      #lines = string.lines
      lines = string.split("\r\n")
      # Create the Plan object:
      line = lines.first
      RTP::verify(line)
      rtp = self.load(line)
      lines[1..-1].each do |line|
        # Validate, determine type, and process the line accordingly to
        # build the hierarchy of records:
        RTP::verify(line)
        values = line.values
        keyword = values.first
        method = RTP::PARSE_METHOD[keyword]
        raise ArgumentError, "Unknown keyword #{keyword} extracted from string." unless method
        rtp.send(method, line)
      end
      return rtp
    end

    # Creates an RTP::Plan instance by reading and parsing an RTPConnect file.
    #
    # === Parameters
    #
    # * <tt>file</tt> -- A string which specifies the path of the RTPConnect file to be loaded.
    #
    def self.read(file)
      raise ArgumentError, "Invalid argument 'file'. Expected String, got #{file.class}." unless file.is_a?(String)
      # Read the file content:
      str = nil
      unless File.exist?(file)
        logger.error("Invalid (non-existing) file: #{file}")
      else
        unless File.readable?(file)
          logger.error("File exists but I don't have permission to read it: #{file}")
        else
          if File.directory?(file)
            logger.error("Expected a file, got a directory: #{file}")
          else
            if File.size(file) < 10
              logger.error("This file is too small to contain valid RTP information: #{file}.")
            else
              str = File.open(file, "rb") { |f| f.read }
            end
          end
        end
      end
      # Parse the file contents and create the RTP::Connect object:
      if str
        rtp = self.parse(str)
      else
        raise "An RTP::Plan object could not be created from the specified file. Check the log for more details."
      end
      return rtp
    end

    # Creates a new Plan.
    #
    def initialize
      @current_parent = self
      # Child records:
      @prescriptions = Array.new
      @dose_trackings = Array.new
      # No parent (by definition) for the Plan record:
      @parent = nil
      @keyword = 'PLAN_DEF'
    end

    # Adds a prescription site record to this instance.
    #
    def add_prescription(child)
      raise ArgumentError, "Invalid argument 'child'. Expected RTP::Prescription, got #{child.class}." unless child.is_a?(RTP::Prescription)
      @prescriptions << child
    end

    # Returns the a properly sorted array of the child records of this instance.
    #
    def children
      return [@prescriptions, @dose_trackings].flatten.compact
    end

    # Returns the values of this instance in an array.
    # The values does not include the CRC.
    #
    def values
      return [
        @keyword,
        @patient_id,
        @patient_last_name,
        @patient_first_name,
        @patient_middle_initial,
        @plan_id,
        @plan_date,
        @plan_time,
        @course_id,
        @diagnosis,
        @md_last_name,
        @md_first_name,
        @md_middle_initial,
        @md_approve_last_name,
        @md_approve_first_name,
        @md_approve_middle_initial,
        @phy_approve_last_name,
        @phy_approve_first_name,
        @phy_approve_middle_initial,
        @author_last_name,
        @author_first_name,
        @author_middle_initial,
        @rtp_mfg,
        @rtp_model,
        @rtp_version,
        @rtp_if_protocol,
        @rtp_if_version
      ]
    end

    # Writes the Plan object + any hiearchy of child objects,
    # to a properly formatted RTPConnect ascii string.
    #
    def to_s
      str = encode #.force_encoding('utf-8')
      children.each do |child|
        str += child.to_s #.force_encoding('utf-8')
      end
      return str
    end

    alias :to_str :to_s

    # Writes the Plan object, along with its hiearchy of child objects,
    # to a properly formatted RTPConnect ascii file.
    #
    # === Parameters
    #
    # * <tt>file</tt> -- A path/file string.
    #
    def write(file)
      f = open_file(file)
      f.write(to_s)
      f.close
    end

    # Sets the keyword attribute.
    #
    def keyword=(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid keyword. Expected 'PLAN_DEF', got #{value}." unless value == "PLAN_DEF"
      @keyword = value
    end

    # Sets the patient_id attribute.
    #
    def patient_id=(value)
      @patient_id = value && value.to_s
    end

    # Sets the patient_last_name attribute.
    #
    def patient_last_name=(value)
      @patient_last_name = value && value.to_s
    end

    # Sets the patient_first_name attribute.
    #
    def patient_first_name=(value)
      @patient_first_name = value && value.to_s
    end

    # Sets the patient_middle_initial attribute.
    #
    def patient_middle_initial=(value)
      @patient_middle_initial = value && value.to_s
    end

    # Sets the plan_id attribute.
    #
    def plan_id=(value)
      @plan_id = value && value.to_s
    end

    # Sets the plan_date attribute.
    #
    def plan_date=(value)
      @plan_date = value && value.to_s
    end

    # Sets the plan_time attribute.
    #
    def plan_time=(value)
      @plan_time = value && value.to_s
    end

    # Sets the course_id attribute.
    #
    def course_id=(value)
      @course_id = value && value.to_s
    end

    # Sets the diagnosis attribute.
    #
    def diagnosis=(value)
      @diagnosis = value && value.to_s
    end

    # Sets the md_last_name attribute.
    #
    def md_last_name=(value)
      @md_last_name = value && value.to_s
    end

    # Sets the md_first_name attribute.
    #
    def md_first_name=(value)
      @md_first_name = value && value.to_s
    end

    # Sets the md_middle_initial attribute.
    #
    def md_middle_initial=(value)
      @md_middle_initial = value && value.to_s
    end

    # Sets the md_approve_last_name attribute.
    #
    def md_approve_last_name=(value)
      @md_approve_last_name = value && value.to_s
    end

    # Sets the md_approve_first_name attribute.
    #
    def md_approve_first_name=(value)
      @md_approve_first_name = value && value.to_s
    end

    # Sets the md_approve_middle_initial attribute.
    #
    def md_approve_middle_initial=(value)
      @md_approve_middle_initial = value && value.to_s
    end

    # Sets the phy_approve_last_name attribute.
    #
    def phy_approve_last_name=(value)
      @phy_approve_last_name = value && value.to_s
    end

    # Sets the phy_approve_first_name attribute.
    #
    def phy_approve_first_name=(value)
      @phy_approve_first_name = value && value.to_s
    end

    # Sets the phy_approve_middle_initial attribute.
    #
    def phy_approve_middle_initial=(value)
      @phy_approve_middle_initial = value && value.to_s
    end

    # Sets the author_last_name attribute.
    #
    def author_last_name=(value)
      @author_last_name = value && value.to_s
    end

    # Sets the author_first_name attribute.
    #
    def author_first_name=(value)
      @author_first_name = value && value.to_s
    end

    # Sets the author_middle_initial attribute.
    #
    def author_middle_initial=(value)
      @author_middle_initial = value && value.to_s
    end

    # Sets the rtp_mfg attribute.
    #
    def rtp_mfg=(value)
      @rtp_mfg = value && value.to_s
    end

    # Sets the rtp_model attribute.
    #
    def rtp_model=(value)
      @rtp_model = value && value.to_s
    end

    # Sets the rtp_version attribute.
    #
    def rtp_version=(value)
      @rtp_version = value && value.to_s
    end

    # Sets the rtp_if_protocol attribute.
    #
    def rtp_if_protocol=(value)
      @rtp_if_protocol = value && value.to_s
    end

    # Sets the rtp_if_version attribute.
    #
    def rtp_if_version=(value)
      @rtp_if_version = value && value.to_s
    end


    private


    # Creates a control point record from the given string.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- An single line string from an RTPConnect ascii file.
    #
    def control_point(string)
      cp = ControlPoint.load(string, @current_parent)
      @current_parent = cp
    end

    # Creates an extended treatment field record from the given string.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- An single line string from an RTPConnect ascii file.
    #
    def extended_treatment_field(string)
      ef = ExtendedField.load(string, @current_parent)
      @current_parent = ef
    end

    # Tests if the path/file is writable, creates any folders if necessary, and opens the file for writing.
    #
    # === Parameters
    #
    # * <tt>file</tt> -- A path/file string.
    #
    def open_file(file)
      # Check if file already exists:
      if File.exist?(file)
        # Is (the existing file) writable?
        unless File.writable?(file)
          #logger.error("The program does not have permission or resources to create this file: #{file}")
          raise "The program does not have permission or resources to create this file: #{file}"
        end
      else
        # File does not exist.
        # Check if this file's path contains a folder that does not exist, and therefore needs to be created:
        folders = file.split(File::SEPARATOR)
        if folders.length > 1
          # Remove last element (which should be the file string):
          folders.pop
          path = folders.join(File::SEPARATOR)
          # Check if this path exists:
          unless File.directory?(path)
            # We need to create (parts of) this path:
            require 'fileutils'
            FileUtils.mkdir_p(path)
          end
        end
      end
      # It has been verified that the file can be created:
      return File.new(file, "wb")
    end

    # Creates a prescription site record from the given string.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- An single line string from an RTPConnect ascii file.
    #
    def prescription_site(string)
      p = Prescription.load(string, @current_parent)
      @current_parent = p
    end

    # Creates a site setup record from the given string.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- An single line string from an RTPConnect ascii file.
    #
    def site_setup(string)
      s = SiteSetup.load(string, @current_parent)
      @current_parent = s
    end

    # Creates a treatment field record from the given string.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- An single line string from an RTPConnect ascii file.
    #
    def treatment_field(string)
      f = Field.load(string, @current_parent)
      @current_parent = f
    end

  end

end