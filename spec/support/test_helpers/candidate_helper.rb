module CandidateHelper
  def create_and_sign_in_candidate
    login_as(current_candidate)
  end

  def candidate_completes_application_form
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(:site, name: 'Main site', code: '-', provider: @provider)
    course = create(:course, exposed_in_find: true, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site: site, course: course, vacancy_status: 'B')

    create_and_sign_in_candidate
    visit candidate_interface_application_form_path

    click_link 'Course choices'
    click_link 'Add another course'
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_button 'Continue'

    select 'Primary (2XT2)'
    click_button 'Continue'

    choose 'Main site'
    click_button 'Continue'

    click_link 'Back to application'

    click_link t('page_titles.personal_details')
    candidate_fills_in_personal_details(scope: 'application_form.personal_details')
    click_button t('complete_form_button', scope: 'application_form.personal_details')
    click_link t('complete_form_button', scope: 'application_form.personal_details')

    click_link t('page_titles.contact_details')
    visit candidate_interface_contact_details_edit_base_path
    candidate_fills_in_contact_details
    click_button t('application_form.contact_details.address.button')
    click_link t('application_form.contact_details.review.button')

    click_link t('page_titles.work_history')
    choose t('application_form.work_history.more_than_5')
    click_button 'Continue'
    candidate_fills_in_work_experience
    click_button t('application_form.work_history.complete_form_button')
    check t('application_form.work_history.review.completed_checkbox')
    click_button t('application_form.work_history.review.button')

    click_link t('page_titles.volunteering.short')
    choose 'Yes' # "Do you have experience volunteering with young people or in school?"
    click_button t('application_form.volunteering.experience.button')
    candidate_fills_in_volunteering_role
    click_button t('application_form.volunteering.complete_form_button')
    check t('application_form.volunteering.review.completed_checkbox')
    click_button t('application_form.volunteering.review.button')

    click_link t('page_titles.degree')
    visit candidate_interface_degrees_new_base_path
    candidate_fills_in_their_degree
    click_button t('application_form.degree.base.button')
    check t('application_form.degree.review.completed_checkbox')
    click_button t('application_form.degree.review.button')

    click_link 'Maths GCSE or equivalent'
    candidate_fills_in_a_gcse
    click_button 'Save and continue'
    click_link 'Back to application'

    click_link 'English GCSE or equivalent'
    candidate_fills_in_a_gcse
    click_button 'Save and continue'
    click_link 'Back to application'

    click_link 'Other relevant academic and non-academic qualifications'
    candidate_fills_in_their_other_qualifications
    click_button t('application_form.other_qualification.base.button')
    check t('application_form.other_qualification.review.completed_checkbox')
    click_button t('application_form.other_qualification.review.button')

    click_link 'Why do you want to be a teacher?'
    fill_in t('application_form.personal_statement.becoming_a_teacher.label'), with: 'I WANT I WANT I WANT I WANT'
    click_button t('application_form.personal_statement.becoming_a_teacher.complete_form_button')
    # Confirmation page
    click_link t('application_form.personal_statement.becoming_a_teacher.complete_form_button')

    click_link 'What do you know about the subject you want to teach?'
    fill_in t('application_form.personal_statement.subject_knowledge.label'), with: 'Everything'
    click_button t('application_form.personal_statement.subject_knowledge.complete_form_button')
    # Confirmation page
    click_link t('application_form.personal_statement.subject_knowledge.complete_form_button')

    click_link 'Interview preferences'
    fill_in t('application_form.personal_statement.interview_preferences.label'), with: 'NOT WEDNESDAY'
    click_button t('application_form.personal_statement.interview_preferences.complete_form_button')
    # Confirmation page
    click_link t('application_form.personal_statement.interview_preferences.complete_form_button')

    candidate_provides_two_referees
  end

  def candidate_submits_application
    click_link 'Check your answers before submitting'
    click_link 'Continue'
    choose 'No' # "Is there anything else you would like to tell us?"

    click_button 'Submit application'

    @application = ApplicationForm.last
  end

  def candidate_fills_in_personal_details(scope:)
    fill_in t('first_name.label', scope: scope), with: 'Lando'
    fill_in t('last_name.label', scope: scope), with: 'Calrissian'

    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'

    select('British', from: t('nationality.label', scope: scope))
    find('details').click
    within('details') do
      select('American', from: t('second_nationality.label', scope: scope))
    end

    choose 'Yes'
    fill_in t('english_main_language.yes_label', scope: scope), with: "I'm great at Galactic Basic so English is a piece of cake", match: :prefer_exact
  end

  def candidate_fills_in_contact_details
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 900 982'
    click_button t('application_form.contact_details.base.button')

    fill_in t('application_form.contact_details.address_line1.label'), with: '42 Much Wow Street'
    fill_in t('application_form.contact_details.address_line3.label'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label'), with: 'SW1P 3BT'
  end

  def candidate_fills_in_their_degree
    fill_in t('application_form.degree.qualification_type.label'), with: 'BA'
    fill_in t('application_form.degree.subject.label'), with: 'Doge'
    fill_in t('application_form.degree.institution_name.label'), with: 'University of Much Wow'

    choose t('application_form.degree.grade.first.label')

    fill_in t('application_form.degree.award_year.label'), with: '2009'
  end

  def candidate_fills_in_their_other_qualifications
    fill_in t('application_form.other_qualification.qualification_type.label'), with: 'A-Level'
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.institution_name.label'), with: 'Yugi College'
    fill_in t('application_form.other_qualification.grade.label'), with: 'A'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
  end

  def candidate_fills_in_work_experience
    with_options scope: 'application_form.work_history' do |locale|
      fill_in locale.t('role.label'), with: 'Teacher'
      fill_in locale.t('organisation.label'), with: 'Oakleaf Primary School'
      choose 'Full-time'

      within('[data-qa="start-date"]') do
        fill_in 'Month', with: '5'
        fill_in 'Year', with: '2014'
      end

      within('[data-qa="end-date"]') do
        fill_in 'Month', with: '1'
        fill_in 'Year', with: '2019'
      end

      fill_in locale.t('details.label'), with: 'I learned a lot about teaching'

      choose 'No'
    end
  end

  def candidate_fills_in_volunteering_role
    with_options scope: 'application_form.volunteering' do |locale|
      fill_in locale.t('role.label'), with: 'Classroom Volunteer'
      fill_in locale.t('organisation.label'), with: 'A Noice School'

      choose 'Yes'

      within('[data-qa="start-date"]') do
        fill_in 'Month', with: '5'
        fill_in 'Year', with: '2018'
      end

      within('[data-qa="end-date"]') do
        fill_in 'Month', with: '1'
        fill_in 'Year', with: '2019'
      end

      fill_in locale.t('details.label'), with: 'I volunteered.'
    end
  end

  def candidate_fills_in_referee(params = {})
    fill_in t('application_form.referees.name.label'), with: params[:name] || 'Terri Tudor'
    fill_in t('application_form.referees.email_address.label'), with: params[:email_address] || 'terri@example.com'
    fill_in t('application_form.referees.relationship.label'), with: params[:relationship] || 'Tutor'
  end

  def candidate_provides_two_referees
    visit candidate_interface_referees_path
    click_link 'Continue'
    candidate_fills_in_referee
    click_button 'Save and continue'
    click_link 'Add a second referee'
    candidate_fills_in_referee(
      name: 'Anne Other',
      email_address: 'anne@other.com',
      relationship: 'First boss',
    )
    click_button 'Save and continue'
    click_link 'Continue'
  end

  def candidate_fills_in_a_gcse
    choose('GCSE')
    click_button 'Save and continue'
    fill_in 'Enter your qualification grade', with: 'B'
    fill_in 'Enter the year you gained your qualification', with: '1990'
  end

  def current_candidate
    @current_candidate ||= create(:candidate)
  end
end
