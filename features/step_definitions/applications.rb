Given(/(an|the) application in "(.*)" state/) do |_, orginal_application_state|
  @application = CandidateApplication.new(state: orginal_application_state.gsub(" ", "_"))
end

When(/a (\w+) (.*)/) do |actor, action|
  event_name = action.gsub(" ", "_").to_sym
  begin
    @application.send(event_name, actor)
  rescue AASM::InvalidTransition
  end
end

When("an application is submitted at {string}") do |timestamp|
  @application = CandidateApplication.create!
  Timecop.freeze(DateTime.parse(timestamp)) do
    @application.submit("candidate")
  end
end

Then("the new application state is {string}") do |new_application_state|
  expect(@application.state).to eq(new_application_state.gsub(" ", "_"))
end

Then("the application's RBD time is {string}") do |timestamp|
  expect(@application.rejected_by_default_at).to eq(DateTime.parse(timestamp))
end

When("the automatic process for rejecting applications is run at {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the application should be automatically rejected: {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("an {string} is able to add conditions: {string}") do |actor, yes_or_no|
  pending # Write code here that turns the phrase above into concrete actions
end

Given("the application stages are set up as follows:") do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  pending # Write code here that turns the phrase above into concrete actions
end

When(/the candidate tries to submit (.*) applications to (\d) different courses at (.*)/) do |stage, number_of_courses, time|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/their submission succeeds: (.*)/) do |yes_or_no|
  pending # Write code here that turns the phrase above into concrete actions
end

Given("the candidate has already submitted {int} applications at Apply 1") do |number_of_applications|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/they can submit more Apply 1 applications: (.*)/) do |yes_or_no|
  pending # Write code here that turns the phrase above into concrete actions
end
