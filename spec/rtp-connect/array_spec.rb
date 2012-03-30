# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe Array do

    describe "#encode" do

      it "should construct the expected, double-quote-wrapped, comma separated string" do
        arr = ['RX_DEF', '70', 'Prost_0-70', '','Xrays', '', '', '', '', '', '', '5']
        str = '"RX_DEF","70","Prost_0-70","","Xrays","","","","","","","5"'
        arr.encode.should eql str
      end

      it "should construct the expected, double-quote-wrapped, comma separated string" do
        arr = ['EXTENDED_FIELD_DEF', '', '', '', 'Anterior, Left', '35786']
        str = '"EXTENDED_FIELD_DEF","","","","Anterior, Left","35786"'
        arr.encode.should eql str
      end

    end

  end

end