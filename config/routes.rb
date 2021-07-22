Rails.application.routes.draw do
  # No Devise modules are enabled
  # Custom, magic-link based authentication flow used. See, for example -
  # CandidateInterface::SignInController
  devise_for :candidates, skip: :all

  devise_scope :candidate do
    get '/candidate/sign-out', to: 'devise/sessions#destroy', as: :candidate_interface_sign_out
  end

  if HostingEnvironment.sandbox_mode?
    root to: 'content#sandbox'
  else
    root to: redirect('/candidate/account')
  end

  namespace :candidate_interface, path: '/candidate' do
    if HostingEnvironment.production?
      get '/' => redirect(GOVUK_APPLY_START_PAGE_URL)
    else
      get '/' => redirect('/')
    end

    get '/accessibility', to: 'content#accessibility'
    get '/cookies', to: 'content#cookies_page', as: :cookies
    get '/make-a-complaint', to: 'content#complaints', as: :complaints
    get '/privacy-policy', to: 'content#privacy_policy', as: :privacy_policy
    get '/providers', to: 'content#providers', as: :providers
    get '/terms-of-use', to: 'content#terms_candidate', as: :terms

    resources :cookie_preferences, only: 'create', path: 'cookie-preferences'
    post '/cookie-preferences-hide-confirmation', to: 'cookie_preferences#hide_confirmation', as: :cookie_preferences_hide_confirmation

    get '/account', to: 'start_page#create_account_or_sign_in', as: :create_account_or_sign_in
    post '/account', to: 'start_page#create_account_or_sign_in_handler'
    get '/applications-closed' => 'start_page#applications_closed', as: :applications_closed

    get '/sign-up', to: 'sign_up#new', as: :sign_up
    post '/sign-up', to: 'sign_up#create'
    get '/sign-up/check-email', to: 'sign_in#check_your_email', as: :check_email_sign_up
    get '/sign-up/external-sign-up-forbidden', to: 'sign_up#external_sign_up_forbidden', as: :external_sign_up_forbidden

    get '/sign-in', to: 'sign_in#new', as: :sign_in
    post '/sign-in', to: 'sign_in#create'
    post '/sign-in/expired', to: 'sign_in#create_from_expired_token', as: :create_expired_sign_in
    get '/sign-in/check-email', to: 'sign_in#check_your_email', as: :check_email_sign_in
    get '/sign-in/expired', to: 'sign_in#expired', as: :expired_sign_in

    get '/confirm_authentication', to: redirect('/candidate/sign-in/confirm')
    get '/sign-in/confirm', to: 'sign_in#confirm_authentication', as: :authenticate
    post '/sign-in/confirm', to: 'sign_in#authenticate'
    get '/authenticate', to: 'sign_in#expired'

    get '/apply', to: 'apply_from_find#show', as: :apply_from_find
    post '/apply', to: 'apply_from_find#choose_service'
    get '/apply/ucas', to: 'apply_from_find#ucas_interstitial', as: :apply_with_ucas_interstitial

    get '/interstitial', to: 'after_sign_in#interstitial', as: :interstitial

    scope '/find-feedback' do
      get '/' => 'find_feedback#new', as: :find_feedback
      post '/' => 'find_feedback#create'
      get '/thank-you' => 'find_feedback#thank_you', as: :find_feedback_thank_you
    end

    scope '/application' do
      get '/prefill', to: 'prefill_application_form#new'
      post '/prefill', to: 'prefill_application_form#create'

      get '/before-you-start', to: 'unsubmitted_application_form#before_you_start'
      get '/' => 'unsubmitted_application_form#show', as: :application_form
      get '/review' => 'unsubmitted_application_form#review', as: :application_review
      get '/submit' => 'unsubmitted_application_form#submit_show', as: :application_submit_show
      post '/submit' => 'unsubmitted_application_form#submit', as: :application_submit

      get '/complete' => 'submitted_application_form#complete', as: :application_complete
      get '/review/submitted' => 'submitted_application_form#review_submitted', as: :application_review_submitted

      get '/review/submitted/:id' => 'application_form#review_previous_application', as: :review_previous_application
      post '/apply-again' => 'submitted_application_form#apply_again', as: :apply_again

      get '/start-carry-over' => 'carry_over#start', as: :start_carry_over
      post '/carry-over' => 'carry_over#create', as: :carry_over

      scope '/personal-details' do
        get '/', to: redirect('/candidate/application/personal-information')
        get '/edit', to: redirect('/candidate/application/personal-information/edit')
        get '/nationalities', to: redirect('/candidate/application/personal-information/nationality'), as: :personal_details_nationalities
        get '/nationalities/edit', to: redirect('/candidate/application/personal-information/nationality/edit'), as: :personal_details_edit_nationalities
        get '/languages', to: redirect('/candidate/application/personal-information/languages'), as: :personal_details_languages
        get '/languages/edit', to: redirect('/candidate/application/personal-information/languages/edit'), as: :personal_details_edit_languages
        get '/right-to-work-or-study', to: redirect('/candidate/application/personal-information/right-to-work-or-study'), as: :personal_details_right_to_work_or_study
        get '/right-to-work-or-study/edit', to: redirect('/candidate/application/personal-information/right-to-work-or-study/edit'), as: :personal_details_edit_right_to_work_or_study
        get 'review', to: redirect('/candidate/application/personal-information/review')
      end

      scope '/personal-information' do
        get '/' => 'personal_details/name_and_dob#new', as: :name_and_dob
        patch '/' => 'personal_details/name_and_dob#create'
        get '/edit' => 'personal_details/name_and_dob#edit', as: :edit_name_and_dob
        patch '/edit' => 'personal_details/name_and_dob#update'

        get '/nationality' => 'personal_details/nationalities#new', as: :nationalities
        patch '/nationality' => 'personal_details/nationalities#create'
        get '/nationality/edit' => 'personal_details/nationalities#edit', as: :edit_nationalities
        patch '/nationality/edit' => 'personal_details/nationalities#update'

        get '/languages' => 'personal_details/languages#new', as: :languages
        patch '/languages' => 'personal_details/languages#create'
        get '/languages/edit' => 'personal_details/languages#edit', as: :edit_languages
        patch '/languages/edit' => 'personal_details/languages#update'

        get '/right-to-work-or-study' => 'personal_details/right_to_work_or_study#new', as: :right_to_work_or_study
        patch '/right-to-work-or-study' => 'personal_details/right_to_work_or_study#create'
        get '/right-to-work-or-study/edit' => 'personal_details/right_to_work_or_study#edit', as: :edit_right_to_work_or_study
        patch '/right-to-work-or-study/edit' => 'personal_details/right_to_work_or_study#update'

        get '/review' => 'personal_details/review#show', as: :personal_details_show
        patch '/review' => 'personal_details/review#complete', as: :personal_details_complete
      end

      scope '/personal-statement' do
        # TODO: Remove redirects from Jan 15 2021
        get '/becoming-a-teacher', to: redirect('/candidate/application/personal-statement')
        get '/becoming-a-teacher/review', to: redirect('/candidate/application/personal-statement/review')
        get '/subject-knowledge', to: redirect('/candidate/application/subject-knowledge')
        get '/subject-knowledge/review', to: redirect('/candidate/application/subject-knowledge/review')
        get '/interview-preferences', to: redirect('/candidate/application/interview-needs')
        get '/interview-preferences/review', to: redirect('/candidate/application/interview-needs/review')

        get '/' => 'personal_statement#new', as: :new_becoming_a_teacher
        patch '/' => 'personal_statement#create'
        get '/edit' => 'personal_statement#edit', as: :edit_becoming_a_teacher
        patch '/edit' => 'personal_statement#update'
        get '/review' => 'personal_statement#show', as: :becoming_a_teacher_show
        patch '/complete' => 'personal_statement#complete', as: :becoming_a_teacher_complete
      end

      scope '/subject-knowledge' do
        get '/' => 'subject_knowledge#new', as: :new_subject_knowledge
        patch '/' => 'subject_knowledge#create'
        get '/edit' => 'subject_knowledge#edit', as: :edit_subject_knowledge
        patch '/edit' => 'subject_knowledge#update'
        get '/review' => 'subject_knowledge#show', as: :subject_knowledge_show
        patch '/complete' => 'subject_knowledge#complete', as: :subject_knowledge_complete
      end

      scope '/interview-needs' do
        get '/' => 'interview_needs#new', as: :new_interview_preferences
        patch '/' => 'interview_needs#create'
        get '/edit' => 'interview_needs#edit', as: :edit_interview_preferences
        patch '/edit' => 'interview_needs#update'
        get '/review' => 'interview_needs#show', as: :interview_preferences_show
        patch '/complete' => 'interview_needs#complete', as: :interview_preferences_complete
      end

      scope '/training-with-a-disability' do
        get '/', to: redirect('/candidate/application/additional-support')
        get '/review', to: redirect('/candidate/application/additional-support/review')
      end

      scope '/additional-support' do
        get '/' => 'training_with_a_disability#new', as: :new_training_with_a_disability
        patch '/' => 'training_with_a_disability#create'
        get '/edit' => 'training_with_a_disability#edit', as: :edit_training_with_a_disability
        patch '/edit' => 'training_with_a_disability#update'
        get '/review' => 'training_with_a_disability#show', as: :training_with_a_disability_show
        patch '/complete' => 'training_with_a_disability#complete', as: :training_with_a_disability_complete
      end

      scope '/contact-details' do
        get '/', to: redirect('/candidate/application/contact-information/phone-number')
        get '/address_type', to: redirect('/candidate/application/contact-information/address-type')
        get '/address', to: redirect('/candidate/application/contact-information/address')
        get '/review', to: redirect('/candidate/application/contact-information/review')
      end

      scope '/contact-information' do
        get '/phone-number' => 'contact_details/phone_number#new', as: :new_phone_number
        post '/phone-number' => 'contact_details/phone_number#create'
        get '/phone-number/edit' => 'contact_details/phone_number#edit', as: :edit_phone_number
        patch '/phone-number/edit' => 'contact_details/phone_number#update'

        get '/address-type' => 'contact_details/address_type#new', as: :new_address_type
        post '/address-type' => 'contact_details/address_type#create'
        get '/address-type/edit' => 'contact_details/address_type#edit', as: :edit_address_type
        patch '/address-type/edit' => 'contact_details/address_type#update'

        get '/address' => 'contact_details/address#new', as: :new_address
        post '/address' => 'contact_details/address#create'
        get '/address/edit' => 'contact_details/address#edit', as: :edit_address
        patch '/address/edit' => 'contact_details/address#update'

        get '/review' => 'contact_details/review#show', as: :contact_information_review
        patch '/complete' => 'contact_details/review#complete', as: :contact_information_complete
      end

      scope '/gcse' do
        get '/maths/grade' => 'gcse/maths/grade#new', as: :new_gcse_maths_grade
        patch '/maths/grade' => 'gcse/maths/grade#create'
        get '/maths/grade/edit' => 'gcse/maths/grade#edit', as: :edit_gcse_maths_grade
        patch '/maths/grade/edit' => 'gcse/maths/grade#update'

        get '/english/grade' => 'gcse/english/grade#new', as: :new_gcse_english_grade
        patch '/english/grade' => 'gcse/english/grade#create'
        get '/english/grade/edit' => 'gcse/english/grade#edit', as: :edit_gcse_english_grade
        patch '/english/grade/edit' => 'gcse/english/grade#update'

        get '/science/grade' => 'gcse/science/grade#new', as: :new_gcse_science_grade
        patch '/science/grade' => 'gcse/science/grade#create'
        get '/science/grade/edit' => 'gcse/science/grade#edit', as: :edit_gcse_science_grade
        patch '/science/grade/edit' => 'gcse/science/grade#update'
      end

      scope '/gcse/:subject', constraints: { subject: /(maths|english|science)/ } do
        get '/' => 'gcse/type#new', as: :gcse_details_new_type
        post '/' => 'gcse/type#create'
        get '/edit' => 'gcse/type#edit', as: :gcse_details_edit_type
        patch '/edit' => 'gcse/type#update'

        get '/country' => 'gcse/institution_country#new', as: :gcse_details_new_institution_country
        patch '/country' => 'gcse/institution_country#create'
        get '/country/edit' => 'gcse/institution_country#edit', as: :gcse_details_edit_institution_country
        patch '/country/edit' => 'gcse/institution_country#update'

        get '/enic' => 'gcse/enic#new', as: :gcse_details_new_enic
        patch '/enic' => 'gcse/enic#create'
        get '/enic/edit' => 'gcse/enic#edit', as: :gcse_details_edit_enic
        patch '/enic/edit' => 'gcse/enic#update'

        get '/grade-explanation' => 'gcse/grade_explanation#new', as: :gcse_details_new_grade_explanation
        patch '/grade-explanation' => 'gcse/grade_explanation#create'
        get '/grade-explanation/edit' => 'gcse/grade_explanation#edit', as: :gcse_details_edit_grade_explanation
        patch '/grade-explanation/edit' => 'gcse/grade_explanation#update'

        get '/year' => 'gcse/year#new', as: :gcse_details_new_year
        patch '/year' => 'gcse/year#create'
        get '/year/edit' => 'gcse/year#edit', as: :gcse_details_edit_year
        patch '/year/edit' => 'gcse/year#update'

        get '/review' => 'gcse/review#show', as: :gcse_review
        patch '/complete' => 'gcse/review#complete', as: :gcse_complete
      end

      scope '/work-history' do
        get '/length' => 'work_history/length#show', as: :work_history_length
        post '/length' => 'work_history/length#submit'

        get '/missing' => 'work_history/explanation#show', as: :work_history_explanation
        post '/missing' => 'work_history/explanation#submit'

        get '/explain-break/new' => 'work_history/break#new', as: :new_work_history_break
        post '/explain-break/new' => 'work_history/break#create'
        get '/explain-break/edit/:id' => 'work_history/break#edit', as: :edit_work_history_break
        patch '/explain-break/edit/:id' => 'work_history/break#update'
        get '/explain-break/delete/:id' => 'work_history/break#confirm_destroy', as: :destroy_work_history_break
        delete '/explain-break/delete/:id' => 'work_history/break#destroy'

        get '/new' => 'work_history/edit#new', as: :new_work_history
        post '/new' => 'work_history/edit#create'

        get '/edit/:id' => 'work_history/edit#edit', as: :work_history_edit
        post '/edit/:id' => 'work_history/edit#update'

        get '/review' => 'work_history/review#show', as: :work_history_show
        patch '/review' => 'work_history/review#complete', as: :work_history_complete

        get '/delete/:id' => 'work_history/destroy#confirm_destroy', as: :work_history_destroy
        delete '/delete/:id' => 'work_history/destroy#destroy'
      end

      scope '/restructured-work-history' do
        get '/' => 'restructured_work_history/start#choice', as: :restructured_work_history
        post '/' => 'restructured_work_history/start#submit_choice'

        get '/new' => 'restructured_work_history/job#new', as: :new_restructured_work_history
        post '/new' => 'restructured_work_history/job#create'

        get '/edit/:id' => 'restructured_work_history/job#edit', as: :edit_restructured_work_history
        patch '/edit/:id' => 'restructured_work_history/job#update'

        get '/delete/:id' => 'restructured_work_history/job#confirm_destroy', as: :destroy_restructured_work_history
        delete '/delete/:id' => 'restructured_work_history/job#destroy'

        get '/explain-break/new' => 'restructured_work_history/break#new', as: :new_restructured_work_history_break
        post '/explain-break/new' => 'restructured_work_history/break#create'

        get '/explain-break/edit/:id' => 'restructured_work_history/break#edit', as: :edit_restructured_work_history_break
        patch '/explain-break/edit/:id' => 'restructured_work_history/break#update'

        get '/explain-break/delete/:id' => 'restructured_work_history/break#confirm_destroy', as: :destroy_restructured_work_history_break
        delete '/explain-break/delete/:id' => 'restructured_work_history/break#destroy'

        get '/review' => 'restructured_work_history/review#show', as: :restructured_work_history_review
        patch '/review' => 'restructured_work_history/review#complete', as: :restructured_work_history_complete
      end

      scope '/school-experience' do
        get '/', to: redirect('/candidate/application/unpaid-experience')
        get '/new', to: redirect('/candidate/application/unpaid-experience/new')
        get '/edit/:id', to: redirect { |params, _| "/candidate/application/unpaid-experience/edit/#{params[:id]}" }
        get '/review', to: redirect('/candidate/application/unpaid-experience/review')
        get '/delete/:id', to: redirect { |params, _| "/candidate/application/unpaid-experience/delete/#{params[:id]}" }
      end

      scope '/unpaid-experience' do
        get '/' => 'volunteering/start#show', as: :volunteering_experience
        post '/' => 'volunteering/start#submit'

        get '/new' => 'volunteering/role#new', as: :new_volunteering_role
        post '/new' => 'volunteering/role#create'

        get '/edit/:id' => 'volunteering/role#edit', as: :edit_volunteering_role
        patch '/edit/:id' => 'volunteering/role#update'

        get '/review' => 'volunteering/review#show', as: :review_volunteering
        patch '/review' => 'volunteering/review#complete', as: :complete_volunteering

        get '/delete/:id' => 'volunteering/destroy#confirm_destroy', as: :confirm_destroy_volunteering_role
        delete '/delete/:id' => 'volunteering/destroy#destroy'
      end

      scope '/degrees' do
        get '/type/(:id)' => 'degrees/type#new', as: :new_degree
        post '/type/(:id)' => 'degrees/type#create'
        get '/:id/type/edit' => 'degrees/type#edit', as: :edit_degree_type
        patch '/:id/type/edit' => 'degrees/type#update'

        get '/:id/subject' => 'degrees/subject#new', as: :degree_subject
        post '/:id/subject' => 'degrees/subject#create'
        get '/:id/subject/edit' => 'degrees/subject#edit', as: :edit_degree_subject
        patch '/:id/subject/edit' => 'degrees/subject#update'

        get '/:id/institution' => 'degrees/institution#new', as: :degree_institution
        post '/:id/institution' => 'degrees/institution#create'
        get '/:id/institution/edit' => 'degrees/institution#edit', as: :edit_degree_institution
        patch '/:id/institution/edit' => 'degrees/institution#update'

        get '/:id/completion_status', to: redirect { |params, _| "/candidate/application/degrees/#{params[:id]}/completion-status" }
        get '/:id/completion_status/edit', to: redirect { |params, _| "/candidate/application/degrees/#{params[:id]}/completion-status/edit" }

        get '/:id/completion-status' => 'degrees/completion_status#new', as: :degree_completion_status
        post '/:id/completion-status' => 'degrees/completion_status#create'
        get '/:id/completion-status/edit' => 'degrees/completion_status#edit', as: :edit_degree_completion_status
        patch '/:id/completion-status/edit' => 'degrees/completion_status#update'

        get '/:id/enic' => 'degrees/enic#new', as: :degree_enic
        post '/:id/enic' => 'degrees/enic#create'
        get '/:id/enic/edit' => 'degrees/enic#edit', as: :edit_degree_enic
        patch '/:id/enic/edit' => 'degrees/enic#update'

        get '/:id/grade' => 'degrees/grade#new', as: :degree_grade
        post '/:id/grade' => 'degrees/grade#create'
        get '/:id/grade/edit' => 'degrees/grade#edit', as: :edit_degree_grade
        patch '/:id/grade/edit' => 'degrees/grade#update'

        get '/:id/year' => 'degrees/year#new', as: :degree_year
        post '/:id/year' => 'degrees/year#create'
        get '/:id/year/edit' => 'degrees/year#edit', as: :edit_degree_year
        patch '/:id/year/edit' => 'degrees/year#update'

        get '/review' => 'degrees/review#show', as: :degrees_review
        patch '/review' => 'degrees/review#complete', as: :degrees_complete

        get '/delete/:id' => 'degrees/destroy#confirm_destroy', as: :confirm_degree_destroy
        delete '/delete/:id' => 'degrees/destroy#destroy'
      end

      scope '/courses' do
        get '/' => 'application_choices#index', as: :course_choices_index

        get '/choose' => 'course_choices/course_decision#ask', as: :course_choices_choose
        post '/choose' => 'course_choices/course_decision#decide'
        get '/find-a-course' => 'course_choices/course_decision#go_to_find', as: :go_to_find
        get '/find_a_course', to: redirect('/candidate/application/courses/find-a-course')

        get '/provider' => 'course_choices/provider_selection#new', as: :course_choices_provider
        post '/provider' => 'course_choices/provider_selection#create'

        get '/provider/:provider_id/courses' => 'course_choices/course_selection#new', as: :course_choices_course
        post '/provider/:provider_id/courses' => 'course_choices/course_selection#create'
        get '/provider/:provider_id/courses/:course_id' => 'course_choices/study_mode_selection#new', as: :course_choices_study_mode
        post '/provider/:provider_id/courses/:course_id' => 'course_choices/study_mode_selection#create'
        get '/provider/:provider_id/courses/:course_id/full' => 'course_choices/course_selection#full', as: :course_choices_full
        get '/provider/:provider_id/courses/:course_id/:study_mode' => 'course_choices/site_selection#new', as: :course_choices_site
        post '/provider/:provider_id/courses/:course_id/:study_mode' => 'course_choices/site_selection#create'
        get '/another' => 'course_choices/add_another_course#ask', as: :course_choices_add_another_course
        post '/another' => 'course_choices/add_another_course#decide', as: :course_choices_add_another_course_selection

        get '/apply-on-ucas/provider/:provider_id' => 'course_choices/ucas#no_courses', as: :course_choices_ucas_no_courses
        get '/apply-on-ucas/provider/:provider_id/course/:course_id' => 'course_choices/ucas#with_course', as: :course_choices_ucas_with_course

        get '/confirm-selection/:course_id' => 'find_course_selections#confirm_selection', as: :course_confirm_selection
        get '/confirm_selection/:course_id', to: redirect('/candidate/application/courses/confirm-selection/%{course_id}')
        post '/complete-selection/:course_id' => 'find_course_selections#complete_selection', as: :course_complete_selection
        get '/complete_selection/:course_id', to: redirect('/candidate/application/courses/complete-selection/%{course_id}')

        get '/review' => 'application_choices#review', as: :course_choices_review
        patch '/review' => 'application_choices#complete', as: :course_choices_complete

        get '/delete/:id' => 'application_choices#confirm_destroy', as: :confirm_destroy_course_choice
        delete '/delete/:id' => 'application_choices#destroy'
      end

      scope '/choice/:id' do
        get '/offer' => 'decisions#offer', as: :offer
        post '/offer/respond' => 'decisions#respond_to_offer', as: :respond_to_offer

        get '/offer/decline' => 'decisions#decline_offer', as: :decline_offer
        post '/offer/decline' => 'decisions#confirm_decline'

        get '/offer/accept' => 'decisions#accept_offer', as: :accept_offer
        post '/offer/accept' => 'decisions#confirm_accept'

        get '/withdraw' => 'decisions#withdraw', as: :withdraw
        post '/withdraw' => 'decisions#confirm_withdraw'

        get '/withdraw/feedback' => 'decisions#withdrawal_feedback', as: :withdrawal_feedback
        post '/withdraw/confirm-feedback' => 'decisions#confirm_withdrawal_feedback', as: :confirm_withdrawal_feedback
      end

      scope '/other-qualifications' do
        get '/' => 'other_qualifications/type#new', as: :other_qualification_type
        post '/' => 'other_qualifications/type#create'
        get '/type/edit/:id' => 'other_qualifications/type#edit', as: :edit_other_qualification_type
        patch '/type/edit/:id' => 'other_qualifications/type#update'

        get '/details' => 'other_qualifications/details#new', as: :other_qualification_details
        patch '/details' => 'other_qualifications/details#create'
        get '/details/edit/:id' => 'other_qualifications/details#edit', as: :edit_other_qualification_details
        patch '/details/edit/:id' => 'other_qualifications/details#update'

        get '/review' => 'other_qualifications/review#show', as: :review_other_qualifications
        patch '/review' => 'other_qualifications/review#complete', as: :complete_other_qualifications

        get '/delete/:id' => 'other_qualifications/destroy#confirm_destroy', as: :confirm_destroy_other_qualification
        delete '/delete/:id' => 'other_qualifications/destroy#destroy'
      end

      scope '/english-as-a-foreign-language' do
        get '/' => 'english_foreign_language/start#new', as: :english_foreign_language_start
        post '/' => 'english_foreign_language/start#create'
        get '/edit' => 'english_foreign_language/start#edit', as: :english_foreign_language_edit_start
        patch '/edit' => 'english_foreign_language/start#update'

        get '/type' => 'english_foreign_language/type#new', as: :english_foreign_language_type
        post '/type' => 'english_foreign_language/type#create'

        get '/ielts' => 'english_foreign_language/ielts#new', as: :ielts
        post '/ielts' => 'english_foreign_language/ielts#create'
        get '/ielts/edit' => 'english_foreign_language/ielts#edit', as: :edit_ielts
        patch '/ielts/edit' => 'english_foreign_language/ielts#update'

        get '/toefl' => 'english_foreign_language/toefl#new', as: :toefl
        post '/toefl' => 'english_foreign_language/toefl#create'
        get '/toefl/edit' => 'english_foreign_language/toefl#edit', as: :edit_toefl
        patch '/toefl/edit' => 'english_foreign_language/toefl#update'

        get '/other' => 'english_foreign_language/other_efl_qualification#new', as: :other_efl_qualification
        post '/other' => 'english_foreign_language/other_efl_qualification#create'
        get '/other/edit' => 'english_foreign_language/other_efl_qualification#edit', as: :edit_other_efl_qualification
        patch '/other/edit' => 'english_foreign_language/other_efl_qualification#update'

        get '/review' => 'english_foreign_language/review#show', as: :english_foreign_language_review
        patch '/review' => 'english_foreign_language/review#complete', as: :english_foreign_language_complete
      end

      scope '/references' do
        get '/start' => 'references/start#show', as: :references_start

        get '/type/(:referee_type)/(:id)' => 'references/type#new', as: :references_type
        post '/type/(:referee_type)/(:id)' => 'references/type#create'
        get '/type/edit/:referee_type/:id' => 'references/type#edit', as: :references_edit_type
        patch '/type/edit/:referee_type/:id' => 'references/type#update'

        scope '/name/:referee_type/(:id)', constraints: { referee_type: /(academic|professional|school-based|character)/ } do
          get '/' => 'references/name#new', as: :references_name
          patch '/' => 'references/name#create'
        end
        get '/name/edit/:id' => 'references/name#edit', as: :references_edit_name
        patch '/name/edit/:id' => 'references/name#update'

        get '/email/:id' => 'references/email_address#new', as: :references_email_address
        patch '/email/:id' => 'references/email_address#create'
        get '/email/edit/:id' => 'references/email_address#edit', as: :references_edit_email_address
        patch '/email/edit/:id' => 'references/email_address#update'

        get '/relationship/:id' => 'references/relationship#new', as: :references_relationship
        patch '/relationship/:id' => 'references/relationship#create'
        get '/relationship/edit/:id' => 'references/relationship#edit', as: :references_edit_relationship
        patch '/relationship/edit/:id' => 'references/relationship#update'

        get '/review-unsubmitted/:id' => 'references/review#unsubmitted', as: :references_review_unsubmitted
        post '/review-unsubmitted/:id' => 'references/review#submit', as: :references_submit

        get '/review' => 'references/review#show', as: :references_review
        get '/review/delete-referee/:id' => 'references/review#confirm_destroy_referee', as: :confirm_destroy_referee
        get '/review/delete-reference/:id' => 'references/review#confirm_destroy_reference', as: :confirm_destroy_reference
        get '/review/delete-reference-request/:id' => 'references/review#confirm_destroy_reference_request', as: :confirm_destroy_reference_request
        delete '/review/delete/:id' => 'references/review#destroy', as: :destroy_reference

        get 'review/cancel/:id' => 'references/review#confirm_cancel', as: :confirm_cancel_reference
        patch 'review/cancel/:id' => 'references/review#cancel', as: :cancel_reference

        get '/request/:id' => 'references/request#new', as: :references_new_request
        post '/request/:id' => 'references/request#create', as: :references_create_request

        get '/retry-request/:id' => 'references/retry_request#new', as: :references_retry_request
        post '/retry-request/:id' => 'references/retry_request#create'

        get '/reminder/:id' => 'references/reminder#new', as: :references_new_reminder
        post '/reminder/:id' => 'references/reminder#create'

        get '/candidate-name/:id' => 'references/candidate_name#new', as: :references_new_candidate_name
        post '/candidate-name/:id' => 'references/candidate_name#create', as: :references_create_candidate_name

        get '/select' => 'references/selection#new', as: :select_references
        patch '/select' => 'references/selection#create'

        get '/select/review' => 'references/selection#review', as: :review_selected_references
        post '/select/review' => 'references/selection#complete', as: :complete_selected_references
      end

      scope '/equality-and-diversity' do
        get '/' => 'equality_and_diversity#start', as: :start_equality_and_diversity
        post '/' => 'equality_and_diversity#choice'

        get '/sex' => 'equality_and_diversity#edit_sex', as: :edit_equality_and_diversity_sex
        patch '/sex' => 'equality_and_diversity#update_sex'

        get '/disability-status' => 'equality_and_diversity#edit_disability_status', as: :edit_equality_and_diversity_disability_status
        patch '/disability-status' => 'equality_and_diversity#update_disability_status'

        get '/disabilities' => 'equality_and_diversity#edit_disabilities', as: :edit_equality_and_diversity_disabilities
        patch '/disabilities' => 'equality_and_diversity#update_disabilities'

        get '/ethnic-group' => 'equality_and_diversity#edit_ethnic_group', as: :edit_equality_and_diversity_ethnic_group
        patch '/ethnic-group' => 'equality_and_diversity#update_ethnic_group'

        get '/ethnic-background' => 'equality_and_diversity#edit_ethnic_background', as: :edit_equality_and_diversity_ethnic_background
        patch '/ethnic-background' => 'equality_and_diversity#update_ethnic_background'

        get '/review' => 'equality_and_diversity#review', as: :review_equality_and_diversity
      end

      scope '/safeguarding' do
        get '/' => 'safeguarding#new', as: :new_safeguarding
        patch '/' => 'safeguarding#create'
        get '/edit' => 'safeguarding#edit', as: :edit_safeguarding
        patch '/edit' => 'safeguarding#update'
        get '/review' => 'safeguarding#show', as: :review_safeguarding
        post '/complete' => 'safeguarding#complete', as: :complete_safeguarding
      end

      scope '/feedback-form' do
        get '/' => 'feedback_form#new', as: :feedback_form
        post '/' => 'feedback_form#create'
        get '/thank-you' => 'feedback_form#thank_you', as: :feedback_form_thank_you
      end

      scope '/application-feedback' do
        get '/' => 'application_feedback#new', as: :application_feedback
        post '/' => 'application_feedback#create'
        get '/thank-you' => 'application_feedback#thank_you', as: :application_feedback_thank_you
      end
    end

    get '*path', to: 'errors#not_found'
  end

  namespace :referee_interface, path: '/reference' do
    get '/' => 'reference#relationship', as: :reference_relationship
    patch '/confirm-relationship' => 'reference#confirm_relationship', as: :confirm_relationship

    get '/safeguarding' => 'reference#safeguarding', as: :safeguarding
    patch '/confirm-safeguarding' => 'reference#confirm_safeguarding', as: :confirm_safeguarding

    get '/feedback' => 'reference#feedback', as: :reference_feedback

    get '/confirmation' => 'reference#confirmation', as: :confirmation
    patch '/confirmation' => 'reference#submit_feedback', as: :submit_feedback

    get '/review' => 'reference#review', as: :reference_review
    patch '/submit' => 'reference#submit_reference', as: :submit_reference

    patch '/questionnaire' => 'reference#submit_questionnaire', as: :submit_questionnaire
    get '/finish' => 'reference#finish', as: :finish

    get '/refuse-feedback' => 'reference#refuse_feedback', as: :refuse_feedback
    patch '/refuse-feedback' => 'reference#confirm_feedback_refusal'

    get '/thank-you' => 'reference#thank_you', as: :thank_you
  end

  namespace :vendor_api, path: 'api/v1' do
    get '/applications' => 'applications#index'
    get '/applications/:application_id' => 'applications#show'

    scope path: '/applications/:application_id' do
      post '/offer' => 'decisions#make_offer'
      post '/confirm-conditions-met' => 'decisions#confirm_conditions_met'
      post '/conditions-not-met' => 'decisions#conditions_not_met'
      post '/reject' => 'decisions#reject'
      post '/confirm-enrolment' => 'decisions#confirm_enrolment'
    end

    post '/test-data/regenerate' => 'test_data#regenerate'
    post '/test-data/generate' => 'test_data#generate'
    post '/test-data/clear' => 'test_data#clear!'

    get '/reference-data/gcse-subjects' => 'reference_data#gcse_subjects'
    get '/reference-data/gcse-grades' => 'reference_data#gcse_grades'
    get '/reference-data/a-and-as-level-subjects' => 'reference_data#a_and_as_level_subjects'
    get '/reference-data/a-and-as-level-grades' => 'reference_data#a_and_as_level_grades'

    post '/experimental/test-data/generate' => 'test_data#experimental_endpoint_moved'
    post '/experimental/test-data/clear' => 'test_data#experimental_endpoint_moved'

    get '/ping', to: 'ping#ping'
  end

  namespace :register_api, path: 'register-api' do
    get '/applications' => 'applications#index'
  end

  namespace :candidate_api, path: 'candidate-api' do
    get '/candidates' => 'candidates#index'
  end

  namespace :provider_interface, path: '/provider' do
    get '/' => 'start_page#show'

    get '/accessibility', to: 'content#accessibility'
    get '/privacy-policy', to: 'content#privacy_policy', as: :privacy_policy
    get '/cookies', to: 'content#cookies_page', as: :cookies
    get '/roadmap', to: 'content#roadmap', as: :roadmap
    get '/make-a-complaint', to: 'content#complaints', as: :complaints
    get '/service-guidance', to: 'content#service_guidance_provider', as: :service_guidance
    get '/covid-19-guidance', to: redirect('/')

    resources :cookie_preferences, only: 'create', path: 'cookie-preferences'
    post '/cookie-preferences-hide-confirmation', to: 'cookie_preferences#hide_confirmation', as: :cookie_preferences_hide_confirmation

    get '/getting-ready-for-next-cycle', to: redirect('/provider/guidance-for-the-new-cycle')
    get '/guidance-for-the-new-cycle', to: 'content#guidance_for_the_new_cycle', as: :guidance_for_the_new_cycle

    get '/data-sharing-agreements/new', to: 'provider_agreements#new_data_sharing_agreement', as: :new_data_sharing_agreement
    post '/data-sharing-agreements', to: 'provider_agreements#create_data_sharing_agreement', as: :create_data_sharing_agreement

    get '/activity' => 'activity_log#index', as: :activity_log

    get '/applications' => 'application_choices#index'

    get '/applications/hesa-export/new' => 'hesa_export#new', as: :new_hesa_export
    get '/applications/hesa-export' => 'hesa_export#export', as: :hesa_export

    get 'applications/data-export/new' => 'application_data_export#new', as: :new_application_data_export
    get 'applications/data-export' => 'application_data_export#export', as: :application_data_export

    scope path: '/applications/:application_choice_id' do
      get '/' => 'application_choices#show', as: :application_choice
      get '/timeline' => 'application_choices#timeline', as: :application_choice_timeline
      get '/emails' => 'application_choices#emails', as: :application_choice_emails
      get '/feedback' => 'application_choices#feedback', as: :application_choice_feedback
      get '/conditions' => 'conditions#edit', as: :application_choice_edit_conditions
      patch '/conditions/confirm' => 'conditions#confirm_update', as: :application_choice_confirm_update_conditions
      patch '/conditions' => 'conditions#update', as: :application_choice_update_conditions

      resource :condition_statuses, only: %i[edit update], path: 'condition-statuses' do
        patch :confirm, on: :collection
      end

      get '/offer/new_withdraw' => redirect('/offer/withdraw')
      post '/offer/confirm_withdraw' => redirect('/offer/confirm-withdraw')
      get '/offer/withdraw' => 'decisions#new_withdraw_offer', as: :application_choice_new_withdraw_offer
      post '/offer/confirm-withdraw' => 'decisions#confirm_withdraw_offer', as: :application_choice_confirm_withdraw_offer
      post '/offer/withdraw' => 'decisions#withdraw_offer', as: :application_choice_withdraw_offer

      get '/offer/defer' => 'decisions#new_defer_offer', as: :application_choice_new_defer_offer
      post '/offer/defer' => 'decisions#defer_offer', as: :application_choice_defer_offer

      resource :decision, only: %i[new create], as: :application_choice_decision

      resource :offers, only: %i[new create show update], as: :application_choice_offer

      namespace :offer, as: :application_choice_offer do
        resource :providers, only: %i[new create edit update]
        resource :courses, only: %i[new create edit update]
        resource :study_modes, only: %i[new create edit update], path: 'study-modes'
        resource :locations, only: %i[new create edit update]
        resource :conditions, only: %i[new create edit update]
        resource :check, only: %i[new edit]
      end

      get '/rejection-reasons' => 'reasons_for_rejection#edit_initial_questions', as: :reasons_for_rejection_initial_questions
      post '/rejection-reasons' => 'reasons_for_rejection#update_initial_questions', as: :reasons_for_rejection_update_initial_questions
      get '/rejection-reasons/other-reasons-for-rejection' => 'reasons_for_rejection#edit_other_reasons', as: :reasons_for_rejection_other_reasons
      post '/rejection-reasons/other-reasons-for-rejection' => 'reasons_for_rejection#update_other_reasons', as: :reasons_for_rejection_update_other_reasons
      get '/rejection-reasons/check' => 'reasons_for_rejection#check', as: :reasons_for_rejection_check
      post '/rejection-reasons/commit' => 'reasons_for_rejection#commit', as: :reasons_for_rejection_commit

      get '/decline-or-withdraw' => 'decline_or_withdraw#edit', as: :decline_or_withdraw_edit
      put '/decline-or-withdraw' => 'decline_or_withdraw#update', as: :decline_or_withdraw_update

      resources :notes, only: %i[index show new create], as: :application_choice_notes

      resources :interviews, only: %i[new edit index], as: :application_choice_interviews do
        collection do
          post '/new/check', to: 'interviews#check'
          post '/confirm', to: 'interviews#commit'
        end

        member do
          get :cancel
          post '/cancel/review/', to: 'interviews#review_cancel'
          post '/cancel/confirm/', to: 'interviews#confirm_cancel'
          post '/check', to: 'interviews#check'
          put '/update', to: 'interviews#update'
        end
      end
    end

    resource :interview_schedule, path: 'interview-schedule', only: :show do
      get :past, on: :collection
    end

    post '/candidates/:candidate_id/impersonate' => 'candidates#impersonate', as: :impersonate_candidate

    get '/sign-in' => 'sessions#new'
    get '/sign-out' => 'sessions#destroy'

    post '/request-sign-in-by-email' => 'sessions#sign_in_by_email', as: :sign_in_by_email
    get '/sign-in/check-email', to: 'sessions#check_your_email', as: :check_your_email
    get '/sign-in-by-email' => 'sessions#authenticate_with_token', as: :authenticate_with_token

    get '/account' => 'account#show'

    scope path: '/account' do
      get '/profile' => 'profile#show'

      scope path: '/users' do
        get '/' => 'provider_users#index', as: :provider_users

        get '/new' => 'provider_users_invitations#edit_details', as: :edit_invitation_basic_details
        post '/new' => 'provider_users_invitations#update_details', as: :update_invitation_basic_details
        get '/new/providers' => 'provider_users_invitations#edit_providers', as: :edit_invitation_providers
        post '/new/providers' => 'provider_users_invitations#update_providers', as: :update_invitation_providers
        get '/new/providers/:provider_id/permissions' => 'provider_users_invitations#edit_permissions', as: :edit_invitation_provider_permissions
        post '/new/providers/:provider_id/permissions' => 'provider_users_invitations#update_permissions', as: :update_invitation_provider_permissions
        get '/new/check' => 'provider_users_invitations#check', as: :check_invitation
        post '/new/commit' => 'provider_users_invitations#commit', as: :commit_invitation

        scope '/:provider_user_id', as: :provider_user do
          get '/' => 'provider_users#show'

          get '/edit-providers' => 'provider_users#edit_providers', as: :edit_providers
          patch '/edit-providers' => 'provider_users#update_providers'

          get '/remove' => 'provider_users#confirm_remove', as: :remove_provider_user
          delete '/remove' => 'provider_users#remove'

          get '/providers/:provider_id/permissions' => 'provider_users#edit_permissions', as: :edit_permissions
          patch '/providers/:provider_id/permissions' => 'provider_users#update_permissions'
        end
      end

      resources :organisations, only: %i[index show], path: 'organisational-permissions'
      resource :notifications, only: %i[show update], path: 'notification-settings'
    end

    resource :organisation_settings, path: '/organisation-settings', only: :show do
      resources :organisations, only: [] do
        get '/' => 'organisation_permissions#organisations', on: :collection
        resources :organisation_permissions, path: '/organisation-permissions', only: %i[index edit update]
      end
    end

    scope path: 'setup' do
      resources :organisation_permissions_setup, only: %i[index edit update], path: 'organisation-permissions' do
        collection do
          get :check
          post :commit
          get :success
        end
      end
    end

    scope path: '/provider-relationship-permissions' do
      get '/organisations-to-setup' => 'provider_relationship_permissions_setup#organisations',
          as: :provider_relationship_permissions_organisations
      get '/:id/setup' => 'provider_relationship_permissions_setup#setup_permissions',
          as: :setup_provider_relationship_permissions
      post '/:id/create' => 'provider_relationship_permissions_setup#save_permissions',
           as: :save_provider_relationship_permissions
      get '/check' => 'provider_relationship_permissions_setup#check',
          as: :check_provider_relationship_permissions
      post '/commit' => 'provider_relationship_permissions_setup#commit',
           as: :commit_provider_relationship_permissions
      get '/success' => 'provider_relationship_permissions_setup#success',
          as: :provider_relationship_permissions_success

      get '/:id/edit' => 'provider_relationship_permissions#edit',
          as: :edit_provider_relationship_permissions
      patch '/:id' => 'provider_relationship_permissions#update',
            as: :update_provider_relationship_permissions
    end

    scope path: '/applications/:application_choice_id/offer/reconfirm' do
      get '/' => 'reconfirm_deferred_offers#start',
          as: :reconfirm_deferred_offer
      get '/conditions' => 'reconfirm_deferred_offers#conditions',
          as: :reconfirm_deferred_offer_conditions
      patch '/conditions' => 'reconfirm_deferred_offers#update_conditions'
      get '/check' => 'reconfirm_deferred_offers#check',
          as: :reconfirm_deferred_offer_check
      post '/' => 'reconfirm_deferred_offers#commit'
    end

    get '*path', to: 'errors#not_found'
  end

  get '/auth/dfe/callback' => 'dfe_sign_in#callback'
  post '/auth/developer/callback' => 'dfe_sign_in#bypass_callback'
  get '/auth/dfe/sign-out' => 'dfe_sign_in#redirect_after_dsi_signout'

  namespace :integrations, path: '/integrations' do
    post '/notify/callback' => 'notify#callback'
    get '/feature-flags' => 'feature_flags#index'
    get '/performance-dashboard' => redirect('support/performance/service')
  end

  namespace :data_api, path: '/data-api' do
    get '/tad-data-exports/latest' => 'tad_data_exports#latest'
    get '/tad-data-exports' => 'tad_data_exports#index'
    get '/tad-data-exports/:id' => 'tad_data_exports#show', as: :tad_export
  end

  namespace :support_interface, path: '/support' do
    get '/' => redirect('/support/applications')

    get '/applications' => 'application_forms#index'

    scope path: '/applications/:application_form_id' do
      get '/' => 'application_forms#show', as: :application_form

      get '/add-course/search' => 'application_forms/courses#new_search', as: :application_form_search_course_new
      post '/add-course/search' => 'application_forms/courses#search', as: :application_form_search_course
      get '/add-course/:course_code' => 'application_forms/courses#new', as: :application_form_new_course
      post '/add-course/:course_code' => 'application_forms/courses#create', as: :application_form_create_course

      get '/audit' => 'application_forms#audit', as: :application_form_audit
      get '/comments/new' => 'application_forms/comments#new', as: :application_form_new_comment
      post '/comments' => 'application_forms/comments#create', as: :application_form_comments

      get '/applicant-details' => 'application_forms/applicant_details#edit', as: :application_form_edit_applicant_details
      post '/applicant-details' => 'application_forms/applicant_details#update', as: :application_form_update_applicant_details

      get '/gcses/:gcse_id' => 'application_forms/gcses#edit', as: :application_form_edit_gcse
      post '/gcses/:gcse_id' => 'application_forms/gcses#update', as: :application_form_update_gcse

      get '/degrees/:degree_id' => 'application_forms/degrees#edit', as: :application_form_edit_degree
      post '/degrees/:degree_id' => 'application_forms/degrees#update', as: :application_form_update_degree

      get '/references/:reference_id/details' => 'application_forms/references#edit_reference_details', as: :application_form_edit_reference_details
      post '/references/:reference_id/details' => 'application_forms/references#update_reference_details', as: :application_form_update_reference_details

      get '/references/:reference_id/feedback' => 'application_forms/references#edit_reference_feedback', as: :application_form_edit_reference_feedback
      post '/references/:reference_id/feedback' => 'application_forms/references#update_reference_feedback', as: :application_form_update_reference_feedback

      get '/applicant-address-type' => 'application_forms/address_type#edit', as: :application_form_edit_address_type
      post '/applicant-address-type' => 'application_forms/address_type#update', as: :application_form_update_address_type
      get '/applicant-address-details' => 'application_forms/address_details#edit', as: :application_form_edit_address_details
      post '/applicant-address-details' => 'application_forms/address_details#update', as: :application_form_update_address_details

      get '/nationalities' => 'application_forms/nationalities#edit', as: :application_form_edit_nationalities
      patch '/nationalities' => 'application_forms/nationalities#update'
      get '/right-to-work-or-study' => 'application_forms/right_to_work_or_study#edit', as: :application_form_edit_right_to_work_or_study
      patch '/right-to-work-or-study' => 'application_forms/right_to_work_or_study#update'

      get '/reinstate-offer/:application_choice_id' => 'application_forms/application_choices/reinstate_declined_offer#confirm_reinstate_offer', as: :application_form_application_choice_reinstate_offer
      patch '/reinstate-offer/:application_choice_id' => 'application_forms/application_choices/reinstate_declined_offer#reinstate_offer'

      get '/change-offered-course-search/:application_choice_id' => 'application_forms/application_choices/change_offered_course#change_offered_course_search', as: :application_form_application_choice_change_offered_course_search
      post '/change-offered-course-search/:application_choice_id' => 'application_forms/application_choices/change_offered_course#search'

      get '/choose-offered-course/:application_choice_id' => 'application_forms/application_choices/change_offered_course#offered_course_options', as: :application_form_application_choice_choose_offered_course_option
      post '/choose-offered-course/:application_choice_id' => 'application_forms/application_choices/change_offered_course#choose_offered_course_option'

      get '/confirm-offered-course/:application_choice_id/:application_choice_id' => 'application_forms/application_choices/change_offered_course#confirm_offered_course_option', as: :application_form_application_choice_confirm_offered_course_option
      patch '/confirm-offered-course/:application_choice_id/:application_choice_id' => 'application_forms/application_choices/change_offered_course#update_offered_course_option'

      get '/revert-rejection/:application_choice_id' => 'application_forms/application_choices#confirm_revert_rejection', as: :application_form_revert_rejection
      patch '/revert-rejection/:application_choice_id' => 'application_forms/application_choices#revert_rejection'
    end

    get '/ucas-matches' => 'ucas_matches#index'

    scope path: '/ucas-matches/:id' do
      get '/' => 'ucas_matches#show', as: :ucas_match
      get '/audit' => 'ucas_matches#audit', as: :ucas_match_audit
      post '/record-ucas-withdrawal-requested' => 'ucas_matches#record_ucas_withdrawal_requested', as: :record_ucas_withdrawal_requested
    end

    get '/duplicate-candidate-matches' => 'duplicate_candidate_matches#index', as: :duplicate_candidate_matches

    get '/application_choices/:application_choice_id' => redirect('/application-choices/%{application_choice_id}')
    get '/application-choices/:application_choice_id' => 'application_choices#show', as: :application_choice
    get '/application-choices/:application_choice_id/conditions' => 'application_choice_conditions#edit', as: :edit_application_choice_conditions
    put '/application-choices/:application_choice_id/conditions' => 'application_choice_conditions#update', as: :update_application_choice_conditions
    get '/application-choices/:application_choice_id/make-unconditional' => 'application_choice_conditions#confirm_make_unconditional', as: :confirm_make_application_choice_unconditional
    put '/application-choices/:application_choice_id/make-unconditional' => 'application_choice_conditions#make_unconditional', as: :make_application_choice_unconditional

    get '/candidates' => 'candidates#index'

    scope path: '/candidates/:candidate_id' do
      get '/' => 'candidates#show', as: :candidate
      post '/hide' => 'candidates#hide_in_reporting', as: :hide_candidate
      post '/show' => 'candidates#show_in_reporting', as: :show_candidate
      post '/impersonate' => 'candidates#impersonate', as: :impersonate_candidate
    end

    scope path: '/references/:reference_id' do
      get '/cancel' => 'references#cancel', as: :cancel_reference
      post '/cancel' => 'references#confirm_cancel'
      get '/reinstate' => 'references#reinstate', as: :reinstate_reference
      post '/reinstate' => 'references#confirm_reinstate'
      get '/impersonate-and-give' => 'references#impersonate_and_give', as: :impersonate_referee_and_give_reference
      get 'impersonate-and-decline' => 'references#impersonate_and_decline', as: :impersonate_referee_and_decline_reference
    end

    get '/tokens' => 'api_tokens#index', as: :api_tokens
    post '/tokens' => 'api_tokens#create'

    get '/providers' => 'providers#index', as: :providers

    scope path: '/providers/users/:provider_user_id' do
      get '/permissions/edit' => 'single_provider_users#edit', as: :edit_permissions
      patch '/permissions' => 'single_provider_users#update', as: :update_permissions
      get '/notifications/edit' => 'single_provider_user_notifications#edit', as: :edit_provider_notifications
      put '/notifications' => 'single_provider_user_notifications#update', as: :update_provider_notifications
      get '/permissions/:provider_permissions_id/remove' => 'single_provider_user_removals#new', as: :provider_user_removals
      delete '/permissions/:provider_permissions_id/remove' => 'single_provider_user_removals#create', as: :remove_provider_user
    end

    scope path: '/providers/:provider_id' do
      get '/' => 'providers#show', as: :provider
      get '/courses' => 'providers#courses', as: :provider_courses
      get '/ratified-courses' => 'providers#ratified_courses', as: :provider_ratified_courses
      get '/vacancies' => 'providers#vacancies', as: :provider_vacancies
      get '/sites' => 'providers#sites', as: :provider_sites
      get '/users' => 'providers#users', as: :provider_user_list
      get '/applications' => 'providers#applications', as: :provider_applications
      get '/history' => 'providers#history', as: :provider_history
      get '/relationships' => 'providers#relationships', as: :provider_relationships
      post '/relationships' => 'providers#update_relationships', as: :update_provider_relationships

      get '/user/new' => 'single_provider_users#new', as: :new_single_provider_user
      post '/user' => 'single_provider_users#create', as: :create_single_provider_user

      namespace :bulk_upload, path: '/bulk-upload' do
        resource :provider_users_details, path: '/provider-users-details', only: %i[new create]
        resource :permissions, only: %i[edit update]
        resource :checks, only: %i[show]
        resource :provider_users, path: '/provider-users', only: %i[create]
      end

      post '' => 'providers#open_all_courses'
      post '/enable_course_syncing' => redirect('/enable-course-syncing')
      post '/enable-course-syncing' => 'providers#enable_course_syncing', as: :enable_provider_course_syncing

      resource :provider_test_data, path: '/test-data', only: %i[create]
    end

    scope path: '/courses/:course_id' do
      get '/' => 'course#show', as: :course
      get '/applications' => 'course#applications', as: :course_applications
      get '/vacancies' => 'course#vacancies', as: :course_vacancies

      post '' => 'course#update'
    end

    scope '/performance' do
      get '/' => 'performance#index', as: :performance

      get '/course-statistics', to: 'performance#courses_dashboard', as: :courses_dashboard
      get '/feature-metrics' => 'performance#feature_metrics_dashboard', as: :feature_metrics_dashboard
      get '/reasons-for-rejection' => 'performance#reasons_for_rejection_dashboard', as: :reasons_for_rejection_dashboard
      get '/reasons-for-rejection/application-choices' => 'performance#reasons_for_rejection_application_choices', as: :reasons_for_rejection_application_choices
      get '/service' => 'performance#service_performance_dashboard', as: :service_performance_dashboard
      get '/ucas-matches' => 'performance#ucas_matches_dashboard', as: :ucas_matches_dashboard

      get '/course-options', to: 'performance#course_options', as: :course_options
      get '/unavailable-choices' => 'performance#unavailable_choices', as: :unavailable_choices
      get '/unavailable-choices/disabled-courses' => 'performance#unavailable_choices_disabled_courses', as: :unavailable_choices_disabled_courses
      get '/unavailable-choices/hidden-courses' => 'performance#unavailable_choices_hidden_courses', as: :unavailable_choices_hidden_courses
      get '/unavailable-choices/removed-sites' => 'performance#unavailable_choices_removed_sites', as: :unavailable_choices_removed_sites
      get '/unavailable-choices/without-vacancies' => 'performance#unavailable_choices_without_vacancies', as: :unavailable_choices_without_vacancies

      get '/data-export/documentation/:export_type_id' => 'data_exports#data_set_documentation', as: :data_set_documentation
      get '/data-directory' => 'data_exports#directory', as: :data_directory
      get '/data-directory/export/:data_export_type' => 'data_exports#view_export_information', as: :view_export_information
      get '/data-directory/export-history' => 'data_exports#history', as: :data_exports_history
      get '/data-directory/export/:data_export_type/history' => 'data_exports#view_history', as: :view_history

      get '/validation-errors' => 'validation_errors#index', as: :validation_errors

      namespace :validation_errors, path: '/validation-errors' do
        scope '/candidate' do
          get '/' => 'candidate#index', as: :candidate
          get '/search' => 'candidate#search', as: :candidate_search
          get '/summary' => 'candidate#summary', as: :candidate_summary
        end

        scope '/provider' do
          get '/' => 'provider#index', as: :provider
          get '/search' => 'provider#search', as: :provider_search
          get '/summary' => 'provider#summary', as: :provider_summary
        end

        scope '/vendor-api' do
          get '/' => 'vendor_api#index', as: :vendor_api
          get '/search' => 'vendor_api#search', as: :vendor_api_search
          get '/summary' => 'vendor_api#summary', as: :vendor_api_summary
        end
      end

      resources :data_exports, path: '/data-exports' do
        member do
          get :download
        end
      end
    end

    get '/email-log', to: 'email_log#index', as: :email_log
    get '/vendor-api-requests', to: 'vendor_api_requests#index', as: :vendor_api_requests

    scope '/settings' do
      get '/' => redirect('/support/settings/feature-flags'), as: :settings
      get '/feature-flags' => 'settings#feature_flags', as: :feature_flags
      post '/feature-flags/:feature_name/activate' => 'settings#activate_feature_flag', as: :activate_feature_flag
      post '/feature-flags/:feature_name/deactivate' => 'settings#deactivate_feature_flag', as: :deactivate_feature_flag

      get '/cycles', to: 'settings#cycles', as: :cycles

      unless HostingEnvironment.production?
        post '/cycles', to: 'settings#switch_cycle_schedule', as: :switch_cycle_schedule
      end

      get '/tasks' => 'tasks#index', as: :tasks
      post '/tasks/create-fake-provider' => 'tasks#create_fake_provider'
      post '/tasks/:task' => 'tasks#run', as: :run_task
      get '/tasks/confirm-delete-test-applications' => 'tasks#confirm_delete_test_applications', as: :confirm_delete_test_applications
      get '/tasks/confirm-cancel-applications-at-end-of-cycle' => 'tasks#confirm_cancel_applications_at_end_of_cycle', as: :confirm_cancel_applications_at_end_of_cycle
    end

    scope '/docs' do
      get '/', to: redirect('/support/docs/candidate-flow'), status: 302, as: :docs
      get '/candidate-flow', to: 'docs#candidate_flow', as: :docs_candidate_flow
      get '/provider-flow', to: 'docs#provider_flow', as: :docs_provider_flow
      get '/when-emails-are-sent', to: 'docs#when_emails_are_sent', as: :docs_when_emails_are_sent
      get '/qualifications', to: 'docs#qualifications', as: :docs_qualifications
      get '/mailers' => 'docs#mailer_previews', as: :docs_mailer_previews
    end

    scope '/users' do
      get '/' => 'users#index', as: :users

      get '/delete/:id' => 'support_users#confirm_destroy', as: :confirm_destroy_support_user
      delete '/delete/:id' => 'support_users#destroy', as: :destroy_support_user
      get '/restore/:id' => 'support_users#confirm_restore', as: :confirm_restore_support_user
      delete '/restore/:id' => 'support_users#restore', as: :restore_support_user

      resources :support_users, only: %i[index new create show], path: :support

      get '/provider/end-impersonation' => 'provider_users#end_impersonation', as: :end_impersonation

      resources :provider_users, only: %i[show index], path: :provider do
        get '/audits' => 'provider_users#audits'
        put '/update-notifications' => 'provider_user_notification_preferences#update_notifications', as: :update_notifications
        post '/impersonate' => 'provider_users#impersonate', as: :impersonate
      end
    end

    get '/sign-in' => 'sessions#new', as: :sign_in
    get '/sign-out' => 'sessions#destroy', as: :sign_out

    get '/confirm-environment' => 'sessions#confirm_environment', as: :confirm_environment
    post '/confirm-environment' => 'sessions#confirmed_environment'

    post '/request-sign-in-by-email' => 'sessions#sign_in_by_email', as: :sign_in_by_email
    get '/sign-in/check-email', to: 'sessions#check_your_email', as: :check_your_email
    get '/sign-in-by-email' => 'sessions#authenticate_with_token', as: :authenticate_with_token

    # https://github.com/mperham/sidekiq/wiki/Monitoring#rails-http-basic-auth-from-routes
    require 'sidekiq/web'
    require 'support_user_constraint'

    mount Sidekiq::Web => '/sidekiq', constraints: SupportUserConstraint.new
    get '/sidekiq', to: redirect('/support/sign-in'), status: 302

    mount Blazer::Engine => '/blazer', constraints: SupportUserConstraint.new
    get '/blazer', to: redirect('/support/sign-in'), status: 302

    get '*path', to: 'errors#not_found'
  end

  namespace :api_docs, path: nil do
    scope module: :vendor_api_docs, path: '/api-docs' do
      get '/' => 'pages#home', as: :home
      get '/usage-scenarios' => 'pages#usage', as: :usage
      get '/reference' => 'reference#reference', as: :reference
      get '/release-notes' => 'pages#release_notes', as: :release_notes
      get '/alpha-release-notes' => 'pages#alpha_release_notes'
      get '/lifecycle' => 'pages#lifecycle'
      get '/when-emails-are-sent' => 'pages#when_emails_are_sent'
      get '/help' => 'pages#help', as: :help
      get '/spec.yml' => 'openapi#spec', as: :spec
    end

    namespace :data_api_docs, path: '/data-api' do
      get '/' => 'reference#reference', as: :home
      get '/spec.yml' => 'open_api#spec', as: :spec
    end

    namespace :register_api_docs, path: '/register-api' do
      get '/' => 'reference#reference', as: :home
      get '/spec.yml' => 'open_api#spec', as: :spec
      get '/release-notes' => 'pages#release_notes', as: :release_notes
    end

    namespace :candidate_api_docs, path: '/candidate-api' do
      get '/' => 'reference#reference', as: :home
      get '/spec.yml' => 'open_api#spec', as: :spec
    end
  end

  get '/check', to: 'healthcheck#show'
  get '/check/version', to: 'healthcheck#version'

  mount Yabeda::Prometheus::Exporter => '/metrics'

  scope via: :all do
    match '/404', to: 'errors#not_found'
    match '/406', to: 'errors#not_acceptable'
    match '/422', to: 'errors#unprocessable_entity'
    match '/500', to: 'errors#internal_server_error'
  end
end
