# encoding: UTF-8

# This file contains extensions to the Ruby library which are used by the RTPConnect library.

# Extension to the String class. These facilitate processing and analysis of RTPConnect strings.
#
class String

  # Determines the checksum (CRC) for a given string.
  #
  # @return [Fixnum] the checksum (a 16 bit unsigned integer)
  #
  def checksum
    crc = RTP::CRC_SEED
    self.each_codepoint do |byte|
      crc = RTP::CRC_TABLE[(crc ^ byte) & 0xff] ^ (crc >> 8)
    end
    return crc
  end

  # Splits the elements of a string separated by comma.
  #
  # @return [Array<String>] an array of the string values originally separated by a comma
  #
  def elements
    self.split(',')
  end

  # Removes leading & trailing double quotes from a string.
  #
  # @return [String] the processed string
  #
  def value
    self.gsub(/\A"|"\Z/, '')
  end

  # Splits the elements of a CSV string (comma separated values) and removes
  # quotation (leading and trailing double-quote characters) from the extracted
  # string elements.
  #
  # @return [Array<String>] an array of the comma separated values
  #
  def values
    begin
      CSV.parse(self).first
    rescue StandardError => e
      RTP.logger.error("Unable to parse the given string record. Probably invalid CSV format: #{self}")
      raise e
    end
  end

  # Wraps double quotes around the string.
  #
  # @return [String] the string padded with double-quotes
  #
  def wrap
    '"' + self + '"'
  end

end


# Extension to the Array class. These facilitate the creation
# of RTPConnect strings from an array of values.
#
class Array

  # Encodes an RTPConnect string from an array of values.
  # Each value in the array is wrapped with double quotes,
  # before the values are joined with a comma separator.
  #
  # @return [String] a proper RTPConnect type CSV string
  #
  def encode
    wrapped = self.collect{|value| value.wrap}
    return wrapped.join(',')
  end

  # Validates the number of elements in an array and converts all elements
  # to strings.
  #
  # @param [Integer] nr the required number of elements in the array
  #
  def validate_and_process(nr)
    raise ArgumentError, "Invalid array length. Expected exactly #{nr} elements, got #{self.length}." unless self.length == nr
    self.collect {|e| e && e.to_s}
  end

end

# An extension to the NilClass, facilitating a transformation from nil to
# an empty (double quoted) string in the case of undefined attributes.
#
class NilClass

  # Gives a double quoted, but otherwise empty string.
  #
  # @return [String] a string containing two double-quotes
  #
  def wrap
    '""'
  end

end