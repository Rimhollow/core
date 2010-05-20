Given /^a stash bin named "([^\"]*)"$/ do |name|
  path = Dir.mktmpdir
  $cleanup << path
  @the_bin = StashBin.new :name => name
  @the_bin.save or raise "could not save stashbin"
end

Then /^there should (be|not be) a stash bin named "([^\"]*)"$/ do |presence, name|

  case presence
  when 'be'
    last_response.should have_selector("td:contains('#{name}')")
  when 'not be'
    last_response.should_not have_selector("td:contains('#{name}')")
  end

end

When /^I press delete on "([^\"]*)"$/ do |bin|
  pending
end

Given /^that stash bin is (empty|not empty)$/ do |contents|

  case contents
  when 'empty'
    pattern = File.join @the_bin.path, '*'
    FileUtils.rm_rf Dir[pattern]

  when 'not empty'
    Given "a workspace with 1 idle wip"
    And "I goto its wip page"
    When %Q(I choose "stash")
    And %Q(I select "#{@the_bin.name}")
    And %Q(I press "Update")

  end

end
