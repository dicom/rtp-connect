# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe ExtendedField do

    before :each do
      @rtp = Plan.new
      @p = Prescription.new(@rtp)
      @f = Field.new(@p)
      @ef = ExtendedField.new(@f)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {ExtendedField.load(42, @f)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an ArgumentError when a non-Field is passed as the 'parent' argument" do
        str = '"EXTENDED_FIELD_DEF","BAKFR","1.3.6.1.4","8","BAKFRA","10442"'
        expect {ExtendedField.load(str, 'not-a-field')}.to raise_error(ArgumentError, /'parent'/)
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"EXTENDED_FIELD_DEF","BAKFR","8","BAKFRA","63164"'
        expect {ExtendedField.load(str, @f)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should create a ExtendedField object when given a valid string" do
        str = '"EXTENDED_FIELD_DEF","BAKFR","1.3.6.1.4","8","BAKFRA","10442"'
        ExtendedField.load(str, @f).class.should eql ExtendedField
      end

      it "should set attributes from the given string" do
        str = '"EXTENDED_FIELD_DEF","BAKFR","1.3.6.1.4","8","BAKFRA","10442"'
        ef = ExtendedField.load(str, @f)
        ef.field_id.should eql 'BAKFR'
        ef.original_beam_number.should eql '8'
      end

    end


    describe "::new" do

      it "should create a ExtendedField object" do
        @ef.class.should eql ExtendedField
      end

      it "should set the parent attribute" do
        @ef.parent.should eql @f
      end

      it "should set the default keyword attribute" do
        @ef.keyword.should eql "EXTENDED_FIELD_DEF"
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        @ef.children.should eql Array.new
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["EXTENDED_FIELD_DEF", [nil]*4].flatten
        @ef.values.should eql arr
      end

    end


    describe "to_s" do

      it "should return a string which matches the original string" do
        str = '"EXTENDED_FIELD_DEF","BAKFR","1.3.6.1.4","8","BAKFRA","10442"' + "\r\n"
        ef = ExtendedField.load(str, @f)
        ef.to_s.should eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"EXTENDED_FIELD_DEF",' + Array.new(4){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        ef = ExtendedField.load(str, @f)
        ef.to_s.should eql str
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'EXTENDED_FIELD_DEF' is given as an argument" do
        expect {@ef.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @ef.keyword = 'EXTENDED_FIELD_DEF'
        @ef.keyword.should eql 'EXTENDED_FIELD_DEF'
      end

    end


    describe "#field_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2'
        @ef.field_id = value
        @ef.field_id.should eql value
      end

    end


    describe "#original_plan_uid=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.2.987'
        @ef.original_plan_uid = value
        @ef.original_plan_uid.should eql value
      end

    end


    describe "#original_beam_number=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '12'
        @ef.original_beam_number = value
        @ef.original_beam_number.should eql value
      end

    end


    describe "#original_beam_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Posterior'
        @ef.original_beam_name = value
        @ef.original_beam_name.should eql value
      end

    end

  end

end
