#    Copyright 2011-2020 Christoffer Lervag
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

  # The Plan class is the highest level Record in the RTPConnect records hierarchy,
  # and the one the user will interact with to read, modify and write files.
  #
  # @note Relations:
  #   * Parent: nil
  #   * Children: Prescription, DoseTracking
  #
  class Plan < Record
    include Logging

    # The Record which this instance belongs to (nil by definition).
    attr_reader :parent
    # An array of Prescription records (if any) that belongs to this Plan.
    attr_reader :prescriptions
    # The ExtendedPlan record (if any) that belongs to this Plan.
    attr_reader :extended_plan
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
    # @note This method does not perform crc verification on the given string.
    #   If such verification is desired, use methods ::parse or ::read instead.
    # @param [#to_s] string the plan definition record string line
    # @param [Hash] options the options to use for loading the plan definition string
    # @option options [Boolean] :repair if true, a record containing invalid CSV will be attempted fixed and loaded
    # @return [Plan] the created Plan instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, options={})
      rtp = self.new
      rtp.load(string, options)
    end

    # Creates a Plan instance by parsing an RTPConnect string.
    #
    # @param [#to_s] string an RTPConnect ascii string (with single or multiple lines/records)
    # @param [Hash] options the options to use for parsing the RTP string
    # @option options [Boolean] :ignore_crc if true, the RTP records will be successfully loaded even if their checksums are invalid
    # @option options [Boolean] :repair if true, any RTP records containing invalid CSV will be attempted fixed and loaded
    # @option options [Boolean] :skip_unknown if true, unknown records will be skipped, and record instances will be built from the remaining recognized string records
    # @return [Plan] the created Plan instance
    # @raise [ArgumentError] if given an invalid string record
    #
    def self.parse(string, options={})
      lines = string.to_s.split("\r\n")
      # Create the Plan object:
      line = lines.first
      RTP.verify(line, options)
      rtp = self.load(line, options)
      lines[1..-1].each do |line|
        # Validate, determine type, and process the line accordingly to
        # build the hierarchy of records:
        RTP.verify(line, options)
        values = line.values(options[:repair])
        keyword = values.first
        method = RTP::PARSE_METHOD[keyword]
        if method
          rtp.send(method, line)
        else
          if options[:skip_unknown]
            logger.warn("Skipped unknown record definition: #{keyword}")
          else
            raise ArgumentError, "Unknown keyword #{keyword} extracted from string."
          end
        end
      end
      return rtp
    end

    # Creates an Plan instance by reading and parsing an RTPConnect file.
    #
    # @param [String] file a string which specifies the path of the RTPConnect file to be loaded
    # @param [Hash] options the options to use for reading the RTP file
    # @option options [Boolean] :ignore_crc if true, the RTP records will be successfully loaded even if their checksums are invalid
    # @option options [Boolean] :repair if true, any RTP records containing invalid CSV will be attempted fixed and loaded
    # @option options [Boolean] :skip_unknown if true, unknown records will be skipped, and record instances will be built from the remaining recognized string records
    # @return [Plan] the created Plan instance
    # @raise [ArgumentError] if given an invalid file or the file given contains an invalid record
    #
    def self.read(file, options={})
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
              str = File.open(file, 'rb:ISO8859-1') { |f| f.read }
            end
          end
        end
      end
      # Parse the file contents and create the RTP instance:
      if str
        rtp = self.parse(str, options)
      else
        raise "An RTP::Plan object could not be created from the specified file. Check the log for more details."
      end
      return rtp
    end

    # Creates a new Plan.
    #
    def initialize
      super('PLAN_DEF', 10, 28)
      @current_parent = self
      # Child records:
      @extended_plan = nil
      @prescriptions = Array.new
      @dose_trackings = Array.new
      # No parent (by definition) for the Plan record:
      @parent = nil
      @attributes = [
        # Required:
        :keyword,
        :patient_id,
        :patient_last_name,
        :patient_first_name,
        :patient_middle_initial,
        :plan_id,
        :plan_date,
        :plan_time,
        :course_id,
        # Optional:
        :diagnosis,
        :md_last_name,
        :md_first_name,
        :md_middle_initial,
        :md_approve_last_name,
        :md_approve_first_name,
        :md_approve_middle_initial,
        :phy_approve_last_name,
        :phy_approve_first_name,
        :phy_approve_middle_initial,
        :author_last_name,
        :author_first_name,
        :author_middle_initial,
        :rtp_mfg,
        :rtp_model,
        :rtp_version,
        :rtp_if_protocol,
        :rtp_if_version
      ]
    end

    # Checks for equality.
    #
    # Other and self are considered equivalent if they are
    # of compatible types and their attributes are equivalent.
    #
    # @param other an object to be compared with self.
    # @return [Boolean] true if self and other are considered equivalent
    #
    def ==(other)
      if other.respond_to?(:to_plan)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # Adds a dose tracking record to this instance.
    #
    # @param [DoseTracking] child a DoseTracking instance which is to be associated with self
    #
    def add_dose_tracking(child)
      @dose_trackings << child.to_dose_tracking
      child.parent = self
    end

    # Adds an extended plan record to this instance.
    #
    # @param [ExtendedPlan] child an ExtendedPlan instance which is to be associated with self
    #
    def add_extended_plan(child)
      @extended_plan = child.to_extended_plan
      child.parent = self
    end

    # Adds a prescription site record to this instance.
    #
    # @param [Prescription] child a Prescription instance which is to be associated with self
    #
    def add_prescription(child)
      @prescriptions << child.to_prescription
      child.parent = self
    end

    # Collects the child records of this instance in a properly sorted array.
    #
    # @return [Array<Prescription, DoseTracking>] a sorted array of self's child records
    #
    def children
      return [@extended_plan, @prescriptions, @dose_trackings].flatten.compact
    end

    # Removes the reference of the given instance from this instance.
    #
    # @param [ExtendedPlan, Prescription, DoseTracking] record a child record to be removed from this instance
    #
    def delete(record)
      case record
      when Prescription
        delete_child(:prescriptions, record)
      when DoseTracking
        delete_child(:dose_trackings, record)
      when ExtendedPlan
        delete_extended_plan
      else
        logger.warn("Unknown class (record) given to Plan#delete: #{record.class}")
      end
    end

    # Removes all dose_tracking references from this instance.
    #
    def delete_dose_trackings
      delete_children(:dose_trackings)
    end

    # Removes the extended plan reference from this instance.
    #
    def delete_extended_plan
      delete_child(:extended_plan)
    end

    # Removes all prescription references from this instance.
    #
    def delete_prescriptions
      delete_children(:prescriptions)
    end

    # Computes a hash code for this object.
    #
    # @note Two objects with the same attributes will have the same hash code.
    #
    # @return [Fixnum] the object's hash code
    #
    def hash
      state.hash
    end

    # Returns self.
    #
    # @return [Plan] self
    #
    def to_plan
      self
    end

    # Returns self.
    #
    # @return [Plan] self
    #
    def to_rtp
      self
    end

    # Writes the Plan object, along with its hiearchy of child objects,
    # to a properly formatted RTPConnect ascii file.
    #
    # @param [String] file a path/file string
    # @param [Hash] options an optional hash parameter
    # @option options [Float] :version the Mosaiq compatibility version number (e.g. 2.4) used for the output
    #
    def write(file, options={})
      f = open_file(file)
      f.write(to_s(options))
      f.close
    end

    # Sets the patient_id attribute.
    #
    # @param [nil, #to_s] value the new attribute value
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
    # @param [nil, #to_s] value the new attribute value
    #
    def patient_first_name=(value)
      @patient_first_name = value && value.to_s
    end

    # Sets the patient_middle_initial attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def patient_middle_initial=(value)
      @patient_middle_initial = value && value.to_s
    end

    # Sets the plan_id attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def plan_id=(value)
      @plan_id = value && value.to_s
    end

    # Sets the plan_date attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def plan_date=(value)
      @plan_date = value && value.to_s
    end

    # Sets the plan_time attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def plan_time=(value)
      @plan_time = value && value.to_s
    end

    # Sets the course_id attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def course_id=(value)
      @course_id = value && value.to_s
    end

    # Sets the diagnosis attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def diagnosis=(value)
      @diagnosis = value && value.to_s
    end

    # Sets the md_last_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def md_last_name=(value)
      @md_last_name = value && value.to_s
    end

    # Sets the md_first_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def md_first_name=(value)
      @md_first_name = value && value.to_s
    end

    # Sets the md_middle_initial attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def md_middle_initial=(value)
      @md_middle_initial = value && value.to_s
    end

    # Sets the md_approve_last_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def md_approve_last_name=(value)
      @md_approve_last_name = value && value.to_s
    end

    # Sets the md_approve_first_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def md_approve_first_name=(value)
      @md_approve_first_name = value && value.to_s
    end

    # Sets the md_approve_middle_initial attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def md_approve_middle_initial=(value)
      @md_approve_middle_initial = value && value.to_s
    end

    # Sets the phy_approve_last_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def phy_approve_last_name=(value)
      @phy_approve_last_name = value && value.to_s
    end

    # Sets the phy_approve_first_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def phy_approve_first_name=(value)
      @phy_approve_first_name = value && value.to_s
    end

    # Sets the phy_approve_middle_initial attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def phy_approve_middle_initial=(value)
      @phy_approve_middle_initial = value && value.to_s
    end

    # Sets the author_last_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def author_last_name=(value)
      @author_last_name = value && value.to_s
    end

    # Sets the author_first_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def author_first_name=(value)
      @author_first_name = value && value.to_s
    end

    # Sets the author_middle_initial attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def author_middle_initial=(value)
      @author_middle_initial = value && value.to_s
    end

    # Sets the rtp_mfg attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rtp_mfg=(value)
      @rtp_mfg = value && value.to_s
    end

    # Sets the rtp_model attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rtp_model=(value)
      @rtp_model = value && value.to_s
    end

    # Sets the rtp_version attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rtp_version=(value)
      @rtp_version = value && value.to_s
    end

    # Sets the rtp_if_protocol attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rtp_if_protocol=(value)
      @rtp_if_protocol = value && value.to_s
    end

    # Sets the rtp_if_version attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rtp_if_version=(value)
      @rtp_if_version = value && value.to_s
    end


    private


    # Creates a control point record from the given string.
    #
    # @param [String] string a string line containing a control point definition
    #
    def control_point(string)
      cp = ControlPoint.load(string, @current_parent)
      @current_parent = cp
    end

    # Creates a dose tracking record from the given string.
    #
    # @param [String] string a string line containing a dose tracking definition
    #
    def dose_tracking(string)
      dt = DoseTracking.load(string, @current_parent)
      @current_parent = dt
    end

    # Creates an extended plan record from the given string.
    #
    # @param [String] string a string line containing an extended plan definition
    #
    def extended_plan_def(string)
      ep = ExtendedPlan.load(string, @current_parent)
      @current_parent = ep
    end

    # Creates an extended treatment field record from the given string.
    #
    # @param [String] string a string line containing an extended treatment field definition
    #
    def extended_treatment_field(string)
      ef = ExtendedField.load(string, @current_parent)
      @current_parent = ef
    end

    # Tests if the path/file is writable, creates any folders if necessary, and opens the file for writing.
    #
    # @param [String] file a path/file string
    # @raise if the given file cannot be created
    #
    def open_file(file)
      # Check if file already exists:
      if File.exist?(file)
        # Is (the existing file) writable?
        unless File.writable?(file)
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
      return File.new(file, 'wb:ISO8859-1')
    end

    # Creates a prescription site record from the given string.
    #
    # @param [String] string a string line containing a prescription site definition
    #
    def prescription_site(string)
      p = Prescription.load(string, @current_parent)
      @current_parent = p
    end

    # Creates a site setup record from the given string.
    #
    # @param [String] string a string line containing a site setup definition
    #
    def site_setup(string)
      s = SiteSetup.load(string, @current_parent)
      @current_parent = s
    end

    # Collects the attributes of this instance.
    #
    # @note The CRC is not considered part of the attributes of interest and is excluded
    # @return [Array<String>] an array of attributes
    #
    alias_method :state, :values

    # Creates a treatment field record from the given string.
    #
    # @param [String] string a string line containing a treatment field definition
    #
    def treatment_field(string)
      f = Field.load(string, @current_parent)
      @current_parent = f
    end

    # Creates a simulation field record from the given string.
    #
    # @param [String] string a string line containing a simulation field definition
    #
    def simulation_field(string)
      sf = SimulationField.load(string, @current_parent)
      @current_parent = sf
    end

  end

end