# encoding: UTF-8

require 'spec_helper'


module RTP

  describe "RTP#leaf_boundaries" do

    it "should raise an ArgumentError when an uknown/unsupported leaf number is given" do
        expect {RTP.leaf_boundaries(999)}.to raise_error(ArgumentError, /leaves/)
      end

    it "should give the expected positions for a 58 leaf MLC (29 leaves on each side)" do
      # Example models: Siemens Primus 58 leaf
      expected = [-200, -135, -125, -115, -105, -95, -85, -75, -65, -55, -45, -35,
        -25, -15, -5, 5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 105, 115, 125, 135, 200
      ]
      RTP.leaf_boundaries(29).should eql expected
    end

    it "should give the expected positions for a 80 leaf MLC (40 leaves on each side)" do
      # Example models: Elekta Synergy 80 leaf, Varian Clinac 80 leaf
      expected = [-200, -190, -180, -170, -160, -150, -140, -130, -120, -110,
        -100, -90, -80, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50,
        60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200
      ]
      RTP.leaf_boundaries(40).should eql expected
    end

    it "should give the expected positions for a 82 leaf MLC (41 leaves on each side)" do
      # Example models: Siemens Oncor 82 leaf
      expected = [-200, -195, -185, -175, -165, -155, -145, -135, -125, -115,
        -105, -95, -85, -75, -65, -55, -45, -35, -25, -15, -5, 5, 15, 25, 35, 45,
        55, 65, 75, 85, 95, 105, 115, 125, 135, 145, 155, 165, 175, 185, 195, 200
      ]
      RTP.leaf_boundaries(41).should eql expected
    end

    it "should give the expected positions for a 120 leaf MLC (60 leaves on each side)" do
      # Example models: Varian Truebeam 120 leaf
      expected = [-200, -190, -180, -170, -160, -150, -140, -130, -120, -110,
        -100, -95, -90, -85, -80, -75, -70, -65, -60, -55, -50, -45, -40, -35, -30,
        -25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65,
        70, 75, 80, 85, 90, 95, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200
      ]
      RTP.leaf_boundaries(60).should eql expected
    end

    it "should give the expected positions for a 160 leaf MLC (80 leaves on each side)" do
      # Example models: Elekta Versa HD 160 leaf
      expected = [-200, -195, -190, -185, -180, -175, -170, -165, -160, -155,
        -150, -145, -140, -135, -130, -125, -120, -115, -110, -105, -100, -95,
        -90, -85, -80, -75, -70, -65, -60, -55, -50, -45, -40, -35, -30, -25, -20,
        -15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75,
        80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 130, 135, 140, 145, 150,
        155, 160, 165, 170, 175, 180, 185, 190, 195, 200
      ]
      RTP.leaf_boundaries(80).should eql expected
    end

  end

  describe "RTP#verify" do

    it "should validate a string which is (correctly) tagged with a single-digit checksum" do
      str = '"PLAN_DEF","","828710","","","","","","","","","","","","","","","","","","","","","","","","","8"'
      RTP.verify(str).should be_true
    end

  end

end