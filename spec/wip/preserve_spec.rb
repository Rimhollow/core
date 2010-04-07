require 'spec_helper'
require 'wip/preserve'

shared_examples_for "all preservations" do

  it "should have every datafile described" do

    @wip.all_datafiles.each do |df|
      @wip.tags.should have_key("step.describe-#{df.id}")
      df.should have_key('describe-file-object')
      df.should have_key('describe-event')
      df.should have_key('describe-agent')
    end

  end

end

describe Wip do

  describe "with no normalization" do
    it_should_behave_like "all preservations"

    before :all do
      @wip = submit 'lorem'
      @wip.preserve!

      @files = {
        :xml => @wip.original_datafiles.find { |df| df['sip-path'] == 'lorem.xml' },
        :txt => @wip.original_datafiles.find { |df| df['sip-path'] == 'lorem_ipsum.txt' },
      }

    end

    it "should not have a normalized representation" do
      @wip.normalized_datafiles.should be_empty
    end

  end

  describe "with one normalization" do
    it_should_behave_like "all preservations"

    before :all do
      @wip = submit 'wave'
      @wip.preserve!
    end

    it "should have an original representation with only an xml and a pdf" do
      o_rep = @wip.original_representation
      o_rep.should have_exactly(2).items
      o_rep[0]['aip-path'].should == 'obj1.wav'
      o_rep[1]['aip-path'].should == 'wave.xml'
    end

    it "should have a current representation just with only an xml and a wav" do
      c_rep = @wip.current_representation
      c_rep.should have_exactly(2).items
      c_rep[0]['aip-path'].should == 'obj1.wav'
      c_rep[1]['aip-path'].should == 'wave.xml'
    end

    it "should have a normalized representation just with only an xml and a wavn" do
      n_rep = @wip.normalized_representation
      n_rep.should have_exactly(2).items
      n_rep[0]['aip-path'].should == '0-norm-0.wav'
      n_rep[1]['aip-path'].should == 'wave.xml'
    end

  end

end
