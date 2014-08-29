# encoding: ASCII-8BIT

# Compatibility specification. The RTPConnect library should be able to read
# and write all these sample files successfully.
# Only reading files checked yet.

require 'spec_helper'


module RTP

  describe Plan do

    describe "::read" do

      it "should raise an exception when given a file with invalid CSV format" do
        expect {Plan.read(RTP_INVALID_QUOTE)}.to raise_error
      end

      it "should parse this RTPConnect Plan record" do
        rtp = Plan.read(RTP_ATTRIBUTE_COMMA)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect Plan record" do
        rtp = Plan.read(RTP_ATTRIBUTE_PAIRS_QUOTES)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect Plan record" do
        rtp = Plan.read(RTP_ATTRIBUTE_QUOTED_COMMA)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_COLUMNA)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_PROSTATE)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_IMRT)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_TANGMAM)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_ELECTRON)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_MOSAIQ_24)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_SIM)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_VMAT)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_VARIAN_NATIVE)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_MOSAIQ_25)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_MOSAIQ_26)
        expect(rtp.class).to eql Plan
      end

    end


    context "with ignore_crc: true" do

      it "should successfully read this file with invalid CRCs" do
        rtp = Plan.read(RTP_INVALID_CRC, ignore_crc: true)
        expect(rtp.patient_id).to eql "123"
        expect(rtp.prescriptions.first.course_id).to eql "7"
      end

    end


    context "with skip_unknown: true" do

      it "should successfully read this file containing an unknown record definition (the unknown record being discarded)" do
        rtp = Plan.read(RTP_UNKNOWN_RECORD, skip_unknown: true)
        expect(rtp.patient_id).to eql "99999"
        expect(rtp.prescriptions.length).to eql 1
        expect(rtp.prescriptions.first.course_id).to eql "2"
      end

    end

  end

end