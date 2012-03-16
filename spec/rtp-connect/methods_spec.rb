# encoding: UTF-8

require 'spec_helper'


module RTP

  describe "RTP#verify" do

    it "should validate a string which is (correctly) tagged with a single-digit checksum" do
      str = '"PLAN_DEF","","828710","","","","","","","","","","","","","","","","","","","","","","","","","8"'
      RTP.verify(str).should be_true
    end

  end

end