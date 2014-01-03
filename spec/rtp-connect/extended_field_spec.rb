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

      it "should raise an error when a non-Field is passed as the 'parent' argument" do
        str = '"EXTENDED_FIELD_DEF","BAKFR","1.3.6.1.4","8","BAKFRA","10442"'
        expect {ExtendedField.load(str, 'not-a-field')}.to raise_error
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"EXTENDED_FIELD_DEF","BAKFR","26947"'
        expect {ExtendedField.load(str, @f)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should give a warning when a string with too many values is passed as the 'string' argument" do
        RTP.logger.expects(:warn).once
        str = '"EXTENDED_FIELD_DEF","2","1.3.6.1","2","AP","1","SQUARE","Applicator","1","2","35677"'
        ef = ExtendedField.load(str, @f)
      end

      it "should create a ExtendedField object when given a valid string" do
        short = '"EXTENDED_FIELD_DEF","2","1.3.6.1","58898"'
        complete = '"EXTENDED_FIELD_DEF","2","1.3.6.1","2","AP","1","SQUARE","Applicator","0","9083"'
        expect(ExtendedField.load(short, @f).class).to eql ExtendedField
        expect(ExtendedField.load(complete, @f).class).to eql ExtendedField
      end

      it "should set attributes from the given string" do
        str = '"EXTENDED_FIELD_DEF","BAKFR","1.3.6.1.4","8","BAKFRA","10442"'
        ef = ExtendedField.load(str, @f)
        expect(ef.field_id).to eql 'BAKFR'
        expect(ef.original_beam_number).to eql '8'
      end

    end


    describe "::new" do

      it "should create a ExtendedField object" do
        expect(@ef.class).to eql ExtendedField
      end

      it "should set the parent attribute" do
        expect(@ef.parent).to eql @f
      end

      it "should set the default keyword attribute" do
        expect(@ef.keyword).to eql "EXTENDED_FIELD_DEF"
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        ef_other = ExtendedField.new(@f)
        ef_other.field_id = '33'
        @ef.field_id = '33'
        expect(@ef == ef_other).to be_true
      end

      it "should be false when comparing two instances having the different attribute values" do
        ef_other = ExtendedField.new(@f)
        ef_other.field_id = '22'
        @ef.field_id = '2'
        expect(@ef == ef_other).to be_false
      end

      it "should be false when comparing against an instance of incompatible type" do
        expect(@ef == 42).to be_false
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        expect(@ef.children).to eql Array.new
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        ef_other = ExtendedField.new(@f)
        ef_other.field_id = '1'
        @ef.field_id = '1'
        expect(@ef == ef_other).to be_true
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"EXTENDED_FIELD_DEF",' + Array.new(4){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        ef1 = ExtendedField.load(str, @f)
        ef2 = ExtendedField.load(str, @f)
        expect(ef1.hash == ef2.hash).to be_true
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["EXTENDED_FIELD_DEF", [nil]*8].flatten
        expect(@ef.values).to eql arr
      end

    end


    describe "#to_extended_field" do

      it "should return itself" do
        expect(@ef.to_extended_field.equal?(@ef)).to be_true
      end

    end


    describe "to_s" do

      it "should return a string which matches the original string" do
        str = '"EXTENDED_FIELD_DEF","2","1.3.6.1","2","AP","1","SQUARE","Applicator","0","9083"' + "\r\n"
        ef = ExtendedField.load(str, @f)
        expect(ef.to_s).to eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"EXTENDED_FIELD_DEF",' + Array.new(8){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        ef = ExtendedField.load(str, @f)
        expect(ef.to_s).to eql str
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'EXTENDED_FIELD_DEF' is given as an argument" do
        expect {@ef.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @ef.keyword = 'EXTENDED_FIELD_DEF'
        expect(@ef.keyword).to eql 'EXTENDED_FIELD_DEF'
      end

    end


    describe "#field_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2'
        @ef.field_id = value
        expect(@ef.field_id).to eql value
      end

    end


    describe "#original_plan_uid=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.2.987'
        @ef.original_plan_uid = value
        expect(@ef.original_plan_uid).to eql value
      end

    end


    describe "#original_beam_number=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '12'
        @ef.original_beam_number = value
        expect(@ef.original_beam_number).to eql value
      end

    end


    describe "#original_beam_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Posterior'
        @ef.original_beam_name = value
        expect(@ef.original_beam_name).to eql value
      end

    end


    describe "#is_fff=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @ef.is_fff = value
        expect(@ef.is_fff).to eql value
      end

    end


    describe "#accessory_code=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'SQUARE'
        @ef.accessory_code = value
        expect(@ef.accessory_code).to eql value
      end

    end


    describe "#accessory_type=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Accessory'
        @ef.accessory_type = value
        expect(@ef.accessory_type).to eql value
      end

    end


    describe "#high_dose_authorization=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @ef.high_dose_authorization = value
        expect(@ef.high_dose_authorization).to eql value
      end

    end

  end

end
