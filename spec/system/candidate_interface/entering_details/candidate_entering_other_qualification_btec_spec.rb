require 'rails_helper'

RSpec.feature 'Entering their other qualifications' do
  include CandidateHelper

  scenario 'Candidate submits their BTEC qualification' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_other_qualifications
    then_i_see_the_select_qualification_type_page

    when_i_select_add_an_other_uk_qualification
    and_i_fill_in_the_qualification_name_as_btec
    and_i_click_continue
    then_i_see_the_add_btec_qualifications_form

    when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    and_i_submit_the_other_qualification_form
    then_i_see_validation_errors_for_my_qualification

    when_i_select_a_grade
    and_i_submit_the_other_qualification_form
    then_i_see_the_other_qualification_review_page
    and_i_should_see_my_qualifications
    and_my_other_uk_qualification_has_the_correct_format
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_other_qualifications
    click_link t('page_titles.other_qualification')
  end

  def then_i_see_the_select_qualification_type_page
    expect(page).to have_current_path(candidate_interface_other_qualification_type_path)
  end

  def when_i_select_add_an_other_uk_qualification
    choose 'Other'
  end

  def and_i_fill_in_the_qualification_name_as_btec
    fill_in 'candidate-interface-other-qualification-type-form-other-uk-qualification-type-field', with: 'BTEC'
  end

  def and_i_click_continue
    click_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_see_the_add_btec_qualifications_form
    expect(page).to have_content('Add BTEC qualification')
  end

  def when_i_fill_in_some_of_my_qualification_but_omit_some_required_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'Music Theory'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
  end

  def and_i_submit_the_other_qualification_form
    click_button t('application_form.other_qualification.base.button')
  end

  def then_i_see_validation_errors_for_my_qualification
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/other_qualification_details_form.attributes.grade.blank')
  end

  def when_i_select_a_grade
    choose 'Merit'
  end

  def then_i_see_the_other_qualification_review_page
    expect(page).to have_current_path(candidate_interface_review_other_qualifications_path)
  end

  def and_i_should_see_my_qualifications
    expect(page).to have_content('BTEC')
    expect(page).to have_content('Music Theory')
    expect(page).to have_content('2015')
    expect(page).to have_content('Merit')
  end

  def and_my_other_uk_qualification_has_the_correct_format
    @application = current_candidate.current_application
    expect(@application.application_qualifications.last.qualification_type).to eq 'Other'
    expect(@application.application_qualifications.last.other_uk_qualification_type).to eq 'BTEC'
    expect(@application.application_qualifications.last.subject).to eq 'Music Theory'
  end
end
