# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe ExtendedPlan do

    before :each do
      @rtp = Plan.new
      @ep = ExtendedPlan.new(@rtp)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {ExtendedPlan.load(42, @rtp)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an error when a non-Plan is passed as the 'parent' argument" do
        expect {ExtendedPlan.load('"EXTENDED_PLAN_DEF","ENCODING=BASE64","FULLNAME=QQBsAGQAZQByAHMAbwBuAF4AUAByAG8AcwB0AGEAdABhAA==","6504"', 'not-a-plan')}.to raise_error
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"EXTENDED_PLAN_DEF","ENCODING=BASE64","50153"'
        expect {ExtendedPlan.load(str, @rtp)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should give a warning when a string with too many values is passed as the 'string' argument" do
        RTP.logger.expects(:warn).once
        str = '"EXTENDED_PLAN_DEF","ENCODING=BASE64","AAFFEEDD==","ANOTHER","39220"'
        ep = ExtendedPlan.load(str, @rtp)
      end

      it "should create an ExtendedPlan object when given a valid string" do
        complete = '"EXTENDED_PLAN_DEF","ENCODING=BASE64","FULLNAME=QQBsAGQAZQByAHMAbwBuAF4AUAByAG8AcwB0AGEAdABhAA==","6504"'
        expect(ExtendedPlan.load(complete, @rtp).class).to eql ExtendedPlan
      end

      it "should set attributes from the given string" do
        str = '"EXTENDED_PLAN_DEF","ENCODING=BASE64","FULLNAME=QQBsAGQAZQByAHMAbwBuAF4AUAByAG8AcwB0AGEAdABhAA==","6504"'
        ep = ExtendedPlan.load(str, @rtp)
        expect(ep.encoding).to eql 'ENCODING=BASE64'
        expect(ep.fullname).to eql 'FULLNAME=QQBsAGQAZQByAHMAbwBuAF4AUAByAG8AcwB0AGEAdABhAA=='
      end

    end


    describe "::new" do

      it "should create an ExtendedPlan object" do
        expect(@ep.class).to eql ExtendedPlan
      end

      it "should set the parent attribute" do
        expect(@ep.parent).to eql @rtp
      end

      it "should set the default keyword attribute" do
        expect(@ep.keyword).to eql "EXTENDED_PLAN_DEF"
      end

      it "should determine the proper parent when given a lower level record in the hiearchy of records" do
        p = Prescription.new(@rtp)
        ep = ExtendedPlan.new(p)
        expect(ep.parent).to eql @rtp
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        ep_other = ExtendedPlan.new(@rtp)
        ep_other.fullname = 'FULLNAME=AFEFAADD'
        @ep.fullname = 'FULLNAME=AFEFAADD'
        expect(@ep == ep_other).to be_true
      end

      it "should be false when comparing two instances having the different attribute values" do
        ep_other = ExtendedPlan.new(@rtp)
        ep_other.fullname = 'FULLNAME=AFEFAADD'
        @ep.fullname = 'FULLNAME=DDCCBBBB'
        expect(@ep == ep_other).to be_false
      end

      it "should be false when comparing against an instance of incompatible type" do
        expect(@ep == 42).to be_false
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        expect(@ep.children).to eql Array.new
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        ep_other = ExtendedPlan.new(@rtp)
        ep_other.fullname = 'FULLNAME=AFEFAADD'
        @ep.fullname = 'FULLNAME=AFEFAADD'
        expect(@ep.eql? ep_other).to be_true
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"EXTENDED_PLAN_DEF",' + Array.new(2){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        ep1 = ExtendedPlan.load(str, @rtp)
        ep2 = ExtendedPlan.load(str, @rtp)
        expect(ep1.hash == ep2.hash).to be_true
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["EXTENDED_PLAN_DEF", [nil]*2].flatten
        expect(@ep.values).to eql arr
      end

    end


    context "#to_extended_plan" do

      it "should return itself" do
        expect(@ep.to_extended_plan.equal?(@ep)).to be_true
      end

    end


    describe "to_s" do

      it "should return a string which matches the original string" do
        str = '"EXTENDED_PLAN_DEF","ENCODING=BASE64","FULLNAME=QQBsAGQAZQByAHMAbwBuAF4AUAByAG8AcwB0AGEAdABhAA==","6504"' + "\r\n"
        ep = ExtendedPlan.load(str, @rtp)
        expect(ep.to_s).to eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"EXTENDED_PLAN_DEF",' + Array.new(2){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        ep = ExtendedPlan.load(str, @rtp)
        expect(ep.to_s).to eql str
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'EXTENDED_PLAN_DEF' is given as an argument" do
        expect {@ep.keyword=('SITE_DEF')}.to raise_error(ArgumentError, /keyword/)
        @ep.keyword = 'EXTENDED_PLAN_DEF'
        expect(@ep.keyword).to eql 'EXTENDED_PLAN_DEF'
      end

    end


    describe "#encoding=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'ENCODING=UTF-8'
        @ep.encoding = value
        expect(@ep.encoding).to eql value
      end

    end


    describe "#fullname=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'FULLNAME=AABBCCDD'
        @ep.fullname = value
        expect(@ep.fullname).to eql value
      end

    end

  end

end
