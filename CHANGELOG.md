# 1.10

## 28th November 2018

* Added support for Mosaiq 2.64, which includes three new iso_pos_x/y/z attributes in the Field and ControlPoint records.

# 1.9

## 23rd March 2016

* Added an variable for retrieving a record's attributes (in an array).
* Added a sample script for beam parameter modification (useful for linac/plan QA purposes).
* Made the parent attribute accessible, and properly update the parent attribute when assigning a record to a new parent.
* Added methods for deleting child records (applies to Plan, Prescription and Field records).


# 1.8

## 19th February 2015

* Fixed an issue with misinterpretation of crc in RTP files from older Mosaiq versions.
* Added support for versioning in RTP file output (supporting versions 2.4, 2.5 & 2.6).
* Fixed an issue where you couldn't access the ExtendedPlan record from its parent Plan record.


# 1.7

## 17th September 2014

* Added a repair option for trying to fix records containing invalid CSV format (i.e. unescaped " characters).
* Added an option for skipping unknown record types when reading an RTPConnect file (instead of raising an error).
* Fixed an issue with writing records containing attributes of mixed encoding.
* Added attributes for table top displacements in the Site Setup record (Mosaiq 2.6).
* Upgraded test suite for Rspec 3.
* Added support for the Extended Plan Definition record (Mosaiq 2.5).
* Added option for ignoring invalid checksums.
* Switched from RDoc to Markdown format.
* Plan#to_dcm improvements.


# 1.6

## 12th December, 2013

* Plan#to_dcm improvements:
  * Added support for VMAT by improving the handling of control point conversion.
  * Made dose reference sequences optional.
  * Order beam limiting device items alphabetically.
  * Added rudimentary support for scale conversion (scale convention = 1 in control point records).
  * More robust extraction of jaw position.
  * More robust handling of cases with missing structure set in the RTP file.
  * Add support for tolerance table sequence.
  * Fixed a bug with missing leaf boundary value for 80 and 160 leaf MLCs.
  * Switched to using fractional cumulative meterset weight, which seems to be more commonly used in commercial systems.
  * Don't create an SSD DICOM element if the SSD attribute in the RTP file is undefined.
  * Only write control point attributes which have changed since the previous/initial control point of each beam.
  * Make sure that the last cumulative meterset weight exactly equals the final cumulative meterset weight.


# 1.5

## 24th October, 2013

* Added support for the Simulation Field record.
* Bumped required Ruby version to 1.9.3.
* More robust CSV implementation:
  * Properly handle attributes containing a double-quote character.
  * Improved handling of invalid CSV RTP files.
  * Ensure that we don't produce invalid CSV with records containing attributes with the double-quote character.
* Plan#to_dcm improvements:
  * Exclude CT & 2DkV fields on export.
  * Properly handle the case of a missing Site Setup in the RTP file.
  * Improve handling of logging in the DICOM module.
  * Added logic for deciding whether the plan's machine actually has an X jaw.
  * Ensure that a correct number of fields and control points are specified.
  * Added support for more MLC types:
    * Siemens 58 & 82 leaf
    * Varian 120 leaf
  * Added options for specifying undeterminable machine information such as:
    * Manufacturer
    * Manufacturer's Model Name
    * Device Serial Number


# 1.4

## 10th April, 2013

* Support an extended ascii character set (ISO8859-1 encoding) for record values and file read/write.


# 1.3

## 12th October, 2012

* Added support for the updated ExtendedField record values introduced in Mosaiq 2.4.
* Simply log a warning instead of raising an exception when reading a record with more values than excpected.
* Allow reading (incomplete) records that contain the required values but not all the optional ones (instead of raising an exception).


# 1.2

## 13th July, 2012

* Converted documentation format from RDoc to YARD.
* Added support for the Dose Tracking record.
* Automatically strip some values which have been observed to have excess whitespace in a Mosaiq RTP export.
* Added the to_dcm conversion method for converting from RTP to DICOM.


# 1.1

## 18th April, 2012

* Added to_* methods for all records to complete the implementation of dynamic typing
* Added comparison related methods to the record classes: #==, #eql? and #hash
* Added the #to_s method to records which may replace the #to_str methods.
* Added dynamic string conversion of parameters, e.g. numeric parameters can be passed to records.
* Fixed an issue where reading string values containing a comma would lead to a crash.
* Fixed an issue where reading a string with a single digit checksum would fail.


# 1.0

## 29th December, 2011

First public release.
The library, although missing support for a number of record types, should be usable
for people interested in working with RTPConnect files in Ruby. The library features
a complete test suite: In addition to basic unit tests, it has been tested successfully
with a small selection of RTPConnect files, and is believed to be fairly robust.