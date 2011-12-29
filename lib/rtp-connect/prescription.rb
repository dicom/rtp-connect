module RTP

  # The Prescription site class.
  #
  # === Relations
  #
  # * Parent: Plan
  # * Children: SiteSetup, (SimulationField), Field
  #
  class Prescription < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    # The SiteSetup record (if any) that belongs to this Prescription.
    attr_reader :site_setup
    # An array of Field records (if any) that belongs to this Prescription.
    attr_reader :fields
    attr_reader :course_id
    attr_reader :rx_site_name
    attr_reader :technique
    attr_reader :modality
    attr_reader :dose_spec
    attr_reader :rx_depth
    attr_reader :dose_ttl
    attr_reader :dose_tx
    attr_reader :pattern
    attr_reader :rx_note
    attr_reader :number_of_fields

    # Creates a new Prescription site by parsing a RTPConnect string line.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- A string containing a prescription site record.
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def self.load(string, parent)
      raise ArgumentError, "Invalid argument 'string'. Expected String, got #{string.class}." unless string.is_a?(String)
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Record, got #{parent.class}." unless parent.is_a?(RTP::Record)
      # Get the quote-less values:
      values = string.values
      raise ArgumentError, "Invalid argument 'string': Expected exactly 13 elements, got #{values.length}." unless values.length == 13
      p = self.new(parent)
      # Assign the values to attributes:
      p.keyword = values[0]
      p.course_id = values[1]
      p.rx_site_name = values[2]
      p.technique = values[3]
      p.modality = values[4]
      p.dose_spec = values[5]
      p.rx_depth = values[6]
      p.dose_ttl = values[7]
      p.dose_tx = values[8]
      p.pattern = values[9]
      p.rx_note = values[10]
      p.number_of_fields = values[11]
      p.crc = values[12]
      return p
    end

    # Creates a new Prescription site.
    #
    # === Parameters
    #
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def initialize(parent)
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Record, got #{parent.class}." unless parent.is_a?(RTP::Record)
      # Child objects:
      @site_setup = nil
      @fields = Array.new
      # Parent relation:
      @parent = get_parent(parent, Plan)
      @parent.add_prescription(self)
      @keyword = 'RX_DEF'
    end

    # Adds a treatment Field record to this instance.
    #
    def add_field(child)
      raise ArgumentError, "Invalid argument 'child'. Expected RTP::Field, got #{child.class}." unless child.is_a?(RTP::Field)
      @fields << child
    end

    # Connects a Site setup record to this instance.
    #
    def add_site_setup(child)
      raise ArgumentError, "Invalid argument 'child'. Expected RTP::SiteSetup, got #{child.class}." unless child.is_a?(RTP::SiteSetup)
      @site_setup = child
    end

    # Returns the a properly sorted array of the child records of this instance.
    #
    def children
      return [@site_setup, @fields].flatten.compact
    end

    # Returns the values of this instance in an array.
    # The values does not include the CRC.
    #
    def values
      return [
        @keyword,
        @course_id,
        @rx_site_name,
        @technique,
        @modality,
        @dose_spec,
        @rx_depth,
        @dose_ttl,
        @dose_tx,
        @pattern,
        @rx_note,
        @number_of_fields
      ]
    end

    # Writes the Prescription object + any hiearchy of child objects,
    # to a properly formatted RTPConnect ascii string.
    #
    def to_str
      str = encode
      if children
        children.each do |child|
          str += child.to_str
        end
      end
      return str
    end

    # Sets the keyword attribute.
    #
    def keyword=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      raise ArgumentError, "Invalid keyword. Expected 'RX_DEF', got #{value}." unless value.upcase == "RX_DEF"
      @keyword = value
    end

    # Sets the course_id attribute.
    #
    def course_id=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @course_id = value
    end

    # Sets the rx_site_name attribute.
    #
    def rx_site_name=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @rx_site_name = value
    end

    # Sets the technique attribute.
    #
    def technique=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @technique = value
    end

    # Sets the modality attribute.
    #
    def modality=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @modality = value
    end

    # Sets the dose_spec attribute.
    #
    def dose_spec=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @dose_spec = value
    end

    # Sets the rx_depth attribute.
    #
    def rx_depth=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @rx_depth = value
    end

    # Sets the dose_ttl attribute.
    #
    def dose_ttl=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @dose_ttl = value
    end

    # Sets the dose_tx attribute.
    #
    def dose_tx=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @dose_tx = value
    end

    # Sets the pattern attribute.
    #
    def pattern=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @pattern = value
    end

    # Sets the rx_note attribute.
    #
    def rx_note=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @rx_note = value
    end

    # Sets the number_of_fields attribute.
    #
    def number_of_fields=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @number_of_fields = value
    end

  end

end