# encoding: utf-8

require 'spec_helper'


module Cql
  describe Frame do
    let :frame do
      described_class.new
    end

    context 'when fed no data' do
      it 'has no length' do
        frame.length.should be_nil
      end

      it 'is not complete' do
        frame.should_not be_complete
      end
    end

    context 'when fed a header' do
      before do
        frame << "\x81\x00\x00\x02\x00\x00\x00\x16"
      end

      it 'knows the frame body length' do
        frame.length.should == 22
      end
    end

    context 'when fed a header in pieces' do
      before do
        frame << "\x81\x00"
        frame << "\x00\x02\x00\x00\x00"
        frame << "\x16"
      end

      it 'knows the body length' do
        frame.length.should == 22
      end
    end

    context 'when fed a request frame header' do
      it 'raises an UnsupportedFrameTypeError' do
        expect { frame << "\x01\x00\x00\x00\x00\x00\x00\x00" }.to raise_error(UnsupportedFrameTypeError)
      end
    end

    context 'when fed a header and a partial body' do
      before do
        frame << "\x81\x00"
        frame << "\x00\x06"
        frame << "\x00\x00\x00\x16"
        frame << [rand(255), rand(255), rand(255), rand(255), rand(255), rand(255), rand(255), rand(255)].pack('C')
      end

      it 'knows the body length' do
        frame.length.should == 22
      end

      it 'is not complete' do
        frame.should_not be_complete
      end
    end

    context 'when fed a complete READY frame' do
      before do
        frame << [0x81, 0, 0, 0x02, 0].pack('C4N')
      end

      it 'is complete' do
        frame.should be_complete
      end
    end

    context 'when fed a complete SUPPORTED frame' do
      before do
        frame << "\x81\x00\x00\x06\x00\x00\x00\x27"
        frame << "\x00\x02\x00\x76CQL_VERSION\x00\x01\x00\x053.0.0\x00\x76COMPRESSION\x00\x00"
      end

      it 'is complete' do
        frame.should be_complete
      end
    end

    context 'when fed an non-existent opcode' do
      it 'raises an UnsupportedOperationError' do
        expect { frame << "\x81\x00\x00\x99\x00\x00\x00\x39" }.to raise_error(UnsupportedOperationError)
      end
    end
  end
end