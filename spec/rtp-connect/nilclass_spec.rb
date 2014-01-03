# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe NilClass do

    describe "#wrap" do

      it "should return a string containing two double-quotes" do
        expect(nil.wrap).to eql '""'
      end

    end

  end

end