require 'spec_helper'
require 'wip'
require 'wip/step'

describe Wip do

  describe "that takes soft steps" do

    it "should make a step tag with the timestamp" do
      wip = submit_sip 'mimi'
      wip.step('add'){ 2 + 3 }
      wip.step_end_time('add').should_not be_nil
      wip.step_end_time('add').should < Time.now
    end

    it "should not perform an operation if the step has been performed" do
      wip = submit_sip 'mimi'
      wip.step('add'){ 2 + 3 }
      time = wip.step_end_time('add')
      sleep 1.5
      wip.step('add'){ 2 + 3 }
      wip.step_end_time('add').should == time
    end

  end

  describe "that takes hard steps" do

    it "should perform an operation even if the step has been performed" do
      wip = submit_sip 'mimi'
      wip.step('add'){ 2 + 3 }
      time = wip.step_end_time('add')
      sleep 1.5
      wip.step!('add'){ 2 + 3 }
      wip.step_end_time('add').should > time
    end

  end

end
