# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe Prescription do

    before :each do
      @rtp = Plan.new
      @p = Prescription.new(@rtp)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {Prescription.load(42, @rtp)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an error when a non-Plan is passed as the 'parent' argument" do
        expect {Prescription.load('"RX_DEF","20","STE:0-20:4","","Xrays","","","","","","","1","17677"', 'not-a-plan')}.to raise_error
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"RX_DEF","2","40685"'
        expect {Prescription.load(str, @rtp)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should give a warning when a string with too many values is passed as the 'string' argument" do
        RTP.logger.expects(:warn).once
        str = '"RX_DEF","20","STE:0-20:4","","Xrays","","","","","","","1","extra","51819"'
        p = Prescription.load(str, @rtp)
      end

      it "should create a Prescription object when given a valid string" do
        short = '"RX_DEF","20","STE:0-20:4","44651"'
        complete = '"RX_DEF","20","STE:0-20:4","","Xrays","","","","","","","1","17677"'
        expect(Prescription.load(short, @rtp).class).to eql Prescription
        expect(Prescription.load(complete, @rtp).class).to eql Prescription
      end

      it "should set attributes from the given string" do
        str = '"RX_DEF","20","STE:0-20:4","","Xrays","","","","","","","1","17677"'
        p = Prescription.load(str, @rtp)
        expect(p.course_id).to eql '20'
        expect(p.modality).to eql 'Xrays'
      end

    end


    describe "::new" do

      it "should create a Prescription object" do
        expect(@p.class).to eql Prescription
      end

      it "should set the parent attribute" do
        expect(@p.parent).to eql @rtp
      end

      it "should by default set the site_setup attribute as nil" do
        expect(@p.site_setup).to be_nil
      end

      it "should by default set the fields attribute as an empty array" do
        expect(@p.fields).to eql Array.new
      end

      it "should set the default keyword attribute" do
        expect(@p.keyword).to eql "RX_DEF"
      end

      it "should determine the proper parent when given a lower level record in the hiearchy of records" do
        f = Field.new(@p)
        cp = ControlPoint.new(f)
        p = Prescription.new(cp)
        expect(p.parent).to eql @rtp
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        p_other = Prescription.new(@rtp)
        p_other.course_id = '7'
        @p.course_id = '7'
        expect(@p == p_other).to be_true
      end

      it "should be false when comparing two instances having the different attribute values" do
        p_other = Prescription.new(@rtp)
        p_other.course_id = '12'
        @p.course_id = '1'
        expect(@p == p_other).to be_false
      end

      it "should be false when comparing against an instance of incompatible type" do
        expect(@p == 42).to be_false
      end

    end


    describe "#add_field" do

      it "should raise an error when a non-Field is passed as the 'child' argument" do
        expect {@p.add_field(42)}.to raise_error
      end

      it "should add the field" do
        p_other = Prescription.new(@rtp)
        f = Field.new(p_other)
        @p.add_field(f)
        expect(@p.fields).to eql [f]
      end

    end


    describe "#add_site_setup" do

      it "should raise an error when a non-SiteSetup is passed as the 'child' argument" do
        expect {@p.add_site_setup(42)}.to raise_error
      end

      it "should add the site setup" do
        p_other = Prescription.new(@rtp)
        ss = SiteSetup.new(p_other)
        @p.add_site_setup(ss)
        expect(@p.site_setup).to eql ss
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        expect(@p.children).to eql Array.new
      end

      it "should return a one-element array containing the Prescription's field" do
        f = Field.new(@p)
        expect(@p.children).to eql [f]
      end

      it "should return a one-element array containing the Prescription's site setup" do
        ss = SiteSetup.new(@p)
        expect(@p.children).to eql [ss]
      end

      it "should return a three-element array containing the Prescription's site setup and two fields" do
        f1 = Field.new(@p)
        f2 = Field.new(@p)
        ss = SiteSetup.new(@p)
        expect(@p.children).to eql [ss, f1, f2]
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        p_other = Prescription.new(@rtp)
        p_other.course_id = '1'
        @p.course_id = '1'
        expect(@p == p_other).to be_true
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"RX_DEF",' + Array.new(11){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        p1 = Prescription.load(str, @rtp)
        p2 = Prescription.load(str, @rtp)
        expect(p1.hash == p2.hash).to be_true
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["RX_DEF", [nil]*11].flatten
        expect(@p.values).to eql arr
      end

    end


    context "#to_prescription" do

      it "should return itself" do
        expect(@p.to_prescription.equal?(@p)).to be_true
      end

    end


    describe "to_s" do

      it "should return a string which matches the original string" do
        str = '"RX_DEF","20","STE:0-20:4","","Xrays","","","","","","","1","17677"' + "\r\n"
        p = Prescription.load(str, @rtp)
        expect(p.to_s).to eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"RX_DEF",' + Array.new(11){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        p = Prescription.load(str, @rtp)
        expect(p.to_s).to eql str
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'RX_DEF' is given as an argument" do
        expect {@p.keyword=('SITE_DEF')}.to raise_error(ArgumentError, /keyword/)
        @p.keyword = 'RX_DEF'
        expect(@p.keyword).to eql 'RX_DEF'
      end

    end


    describe "#course_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @p.course_id = value
        expect(@p.course_id).to eql value
      end

    end


    describe "#rx_site_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Prostate'
        @p.rx_site_name = value
        expect(@p.rx_site_name).to eql value
      end

    end


    describe "#technique=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Box'
        @p.technique = value
        expect(@p.technique).to eql value
      end

    end


    describe "#modality=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6X'
        @p.modality = value
        expect(@p.modality).to eql value
      end

    end


    describe "#dose_spec=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Plan'
        @p.dose_spec = value
        expect(@p.dose_spec).to eql value
      end

    end


    describe "#rx_depth=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '19'
        @p.rx_depth = value
        expect(@p.rx_depth).to eql value
      end

    end


    describe "#dose_ttl=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '7000'
        @p.dose_ttl = value
        expect(@p.dose_ttl).to eql value
      end

    end


    describe "#dose_tx=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '200'
        @p.dose_tx = value
        expect(@p.dose_tx).to eql value
      end

    end


    describe "#pattern=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Daily'
        @p.pattern = value
        expect(@p.pattern).to eql value
      end

    end


    describe "#rx_note=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Note'
        @p.rx_note = value
        expect(@p.rx_note).to eql value
      end

    end


    describe "#number_of_fields=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4'
        @p.number_of_fields = value
        expect(@p.number_of_fields).to eql value
      end

    end

  end

end
