Given /^an archived package$/ do
  wip = submit 'mimi'
  wip.start_task
  sleep 0.5 until !wip.running?
end

When /^I goto its package page$/ do
  id = sips.last[:wip]
  visit "/package/#{id}"
end

Then /^in the submission summary I should see the (sip|account|project)$/ do |field|
  last_response.should have_selector("th:contains('#{field}') + td")
end

Then /^in the jobs summary I should see an ingest wip$/ do
  id = sips.last[:wip]
  last_response.should have_selector("a[href='/workspace/#{id}']:contains('ingest')")
end

Then /^in the events I should see a submission event$/ do
  last_response.should have_selector("td:contains('Package Submission')")
end

Then /^in the aip section I should see (copy url|copy size|copy sha1|number of datafiles)$/ do |field|
  last_response.should have_selector("th:contains('#{field}') + td")
end

Then /^in the aip section I should see a link to the descriptor$/ do
  id = sips.last[:wip]
  last_response.should have_selector("h3 a[href='/package/#{id}/descriptor']:contains('xml descriptor')")
end