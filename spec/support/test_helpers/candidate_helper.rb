module CandidateHelper
  def create_and_sign_in_candidate
    login_as(current_candidate)
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

  def current_candidate
    @current_candidate ||= create(:candidate)
  end
end
