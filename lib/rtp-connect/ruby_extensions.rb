# encoding: UTF-8

# This file contains extensions to the Ruby library which are used by the RTPConnect library.

# Extension to the String class. These extensions are focused on analyzing RTPConnect strings.
#
class String

  # Returns the CRC checksum (16 bit unsigned integer) for a given string.
  #
  def checksum
    crc = RTP::CRC_SEED
    self.each_codepoint do |byte|
      crc = RTP::CRC_TABLE[(crc ^ byte) & 0xff] ^ (crc >> 8)
    end
    return crc
  end

  # Returns the elements of a line from the RTPConnect ascii string.
  # The line consists of elements (surrounded by double quotes), separated by comma.
  # This method performs a split based on comma and returns the element strings in an array.
  #
  def elements
    return self.split(',')
  end

  # Removes double quotes from a string.
  # Returns the quote-less string.
  #
  def value
    return self.gsub('"', '')
  end

  # Returns the element values of a line from the RTPConnect ascii string.
  # The line consists of values (surrounded by double quotes), separated by comma.
  # This method performs a split based on comma and removes the quotes from each value,
  # and the resulting quote-less value strings are returned in an array.
  #
  def values
    original = CSV.parse(self).first
    processed = Array.new
    original.collect {|element| processed << element.gsub('"', '')}
    return processed
  end

  # Wraps double quotes around the string.
  #
  def wrap
    return '"' + self + '"'
  end

end


# Extension to the Array class. These extensions are focused on creating RTPConnect
# strings from an array of values.
#
class Array

  # Encodes an RTPConnect string from an array of values.
  # Each value in the array is wrapped with double quotes,
  # before the values are joined with a comma separator.
  #
  def encode
    wrapped = self.collect{|value| value.wrap}
    return wrapped.join(',')
  end

end

# An extension to the NilClass, facilitating a transformation from nil to
# an empty (double quoted) string in the case of undefined attributes.
#
class NilClass

  # Returns a double quoted, but otherwise empty string.
  #
  def wrap
    return '""'
  end

end