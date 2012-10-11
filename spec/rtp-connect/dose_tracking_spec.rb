# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe DoseTracking do

    before :each do
      @rtp = Plan.new
      @dt = DoseTracking.new(@rtp)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {DoseTracking.load(42, @rtp)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an error when a non-Plan is passed as the 'parent' argument" do
        str = '"DOSE_DEF","V.Orbita 0-30","","6","1.00000","","","","","","","","","","","","","","","","","","","","","29762"'
        expect {DoseTracking.load(str, 'not-a-plan')}.to raise_error
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"DOSE_DEF","V.Orbita 0-30","","6","1.00000","","","","","","","","","","","","","","","","","","29778"'
        expect {DoseTracking.load(str, @rtp)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should give a warning when a string with too many values is passed as the 'string' argument" do
        RTP.logger.expects(:warn).once
        str = '"DOSE_DEF","V.Orbita 0-30","","6","1.00000","","","","","","","","","","","","","","","","","","","","","extra","33262"'
        dt = DoseTracking.load(str, @rtp)
      end

      it "should create a DoseTracking object when given a valid string" do
        short = '"DOSE_DEF","V.Orbita 0-30","","6","1.00000","","","","","","","","","","","","","","","","","","","42559"'
        complete = '"DOSE_DEF","V.Orbita 0-30","","6","1.00000","","","","","","","","","","","","","","","","","","","","","29762"'
        DoseTracking.load(short, @rtp).class.should eql DoseTracking
        DoseTracking.load(complete, @rtp).class.should eql DoseTracking
      end

      it "should set attributes from the given string" do
        str = '"DOSE_DEF","V.Orbita 0-30","","6","1.00000","","","","","","","","","","","","","","","","","","","","","29762"'
        dt = DoseTracking.load(str, @rtp)
        dt.region_name.should eql 'V.Orbita 0-30'
        dt.field_ids[0].should eql '6'
      end

    end


    describe "::new" do

      it "should create a DoseTracking object" do
        @dt.class.should eql DoseTracking
      end

      it "should set the parent attribute" do
        @dt.parent.should eql @rtp
      end

      it "should set the default keyword attribute" do
        @dt.keyword.should eql "DOSE_DEF"
      end

      it "should determine the proper parent when given a lower level record in the hiearchy of records" do
        p = Prescription.new(@rtp)
        f = Field.new(p)
        dt = DoseTracking.new(f)
        dt.parent.should eql @rtp
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        dt_other = DoseTracking.new(@rtp)
        dt_other.region_name = 'Prostate'
        @dt.region_name = 'Prostate'
        (@dt == dt_other).should be_true
      end

      it "should be false when comparing two instances having the different attribute values" do
        dt_other = DoseTracking.new(@rtp)
        dt_other.region_name = 'Prostate'
        @dt.region_name = 'Brain'
        (@dt == dt_other).should be_false
      end

      it "should be false when comparing against an instance of incompatible type" do
        (@dt == 42).should be_false
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        @dt.children.should eql Array.new
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        dt_other = DoseTracking.new(@rtp)
        dt_other.region_name = 'Brain'
        @dt.region_name = 'Brain'
        (@dt == dt_other).should be_true
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"DOSE_DEF",' + Array.new(24){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        dt1 = DoseTracking.load(str, @rtp)
        dt2 = DoseTracking.load(str, @rtp)
        (dt1.hash == dt2.hash).should be_true
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["DOSE_DEF", [nil]*24].flatten
        @dt.values.should eql arr
      end

    end


    describe "#to_dose_tracking" do

      it "should return itself" do
        @dt.to_dose_tracking.equal?(@dt).should be_true
      end

    end


    describe "to_s" do

      it "should return a string which matches the original string" do
        str = '"DOSE_DEF","V.Orbita 0-30","","6","1.00000","","","","","","","","","","","","","","","","","","","","","29762"' + "\r\n"
        dt = DoseTracking.load(str, @rtp)
        dt.to_s.should eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"DOSE_DEF",' + Array.new(24){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        dt = DoseTracking.load(str, @rtp)
        dt.to_s.should eql str
      end

    end


    describe "#field_ids=()" do

      it "should raise an error if the specified array has less than 10 elements" do
        expect {@dt.field_ids=(Array.new(9, ''))}.to raise_error(ArgumentError, /'array'/)
      end

      it "should raise an error if the specified array has more than 10 elements" do
        expect {@dt.field_ids=(Array.new(11, ''))}.to raise_error(ArgumentError, /'array'/)
      end

      it "should transfer the array (containing string and nil values) to the field_ids attribute" do
        arr = Array.new(10)
        arr[1] = '1'
        arr[9] = '5'
        @dt.field_ids = arr
        @dt.field_ids.should eql arr
      end

      it "should transfer the array (containing only string values) to the field_ids attribute" do
        arr =Array.new(10) {|i| (i-5).to_f.to_s}
        @dt.field_ids = arr
        @dt.field_ids.should eql arr
      end

    end


    describe "#region_coeffs=()" do

      it "should raise an error if the specified array has less than 10 elements" do
        expect {@dt.region_coeffs=(Array.new(9, ''))}.to raise_error(ArgumentError, /'array'/)
      end

      it "should raise an error if the specified array has more than 10 elements" do
        expect {@dt.region_coeffs=(Array.new(11, ''))}.to raise_error(ArgumentError, /'array'/)
      end

      it "should transfer the array (containing string and nil values) to the region_coeffs attribute" do
        arr = Array.new(10)
        arr[1] = '1.00'
        arr[9] = '2.00'
        @dt.region_coeffs = arr
        @dt.region_coeffs.should eql arr
      end

      it "should transfer the array (containing only string values) to the region_coeffs attribute" do
        arr =Array.new(10) {|i| (i-5).to_f.to_s}
        @dt.region_coeffs = arr
        @dt.region_coeffs.should eql arr
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'DOSE_DEF' is given as an argument" do
        expect {@dt.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @dt.keyword = 'DOSE_DEF'
        @dt.keyword.should eql 'DOSE_DEF'
      end

    end


    describe "#region_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Brain'
        @dt.region_name = value
        @dt.region_name.should eql value
      end

    end


    describe "#region_prior_dose=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '200'
        @dt.region_prior_dose = value
        @dt.region_prior_dose.should eql value
      end

    end


    describe "#actual_dose=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '400'
        @dt.actual_dose = value
        @dt.actual_dose.should eql value
      end

    end


    describe "#actual_fractions=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '10'
        @dt.actual_fractions = value
        @dt.actual_fractions.should eql value
      end

    end

  end

end
