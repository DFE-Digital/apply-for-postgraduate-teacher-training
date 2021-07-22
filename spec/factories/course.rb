FactoryBot.define do
  factory :course do
    provider

    code { Faker::Alphanumeric.alphanumeric(number: 4, min_alpha: 1).upcase }
    name { Faker::Educator.subject }
    level { 'primary' }
    recruitment_cycle_year { RecruitmentCycle.current_year }
    description { 'PGCE with QTS full time' }
    course_length { 'OneYear' }
    start_date { Faker::Date.between(from: 1.month.from_now, to: 1.year.from_now) }
    age_range { '4 to 8' }
    withdrawn { false }

    funding_type { %w[fee salary apprenticeship].sample }
    course_subjects { [association(:course_subject, course: instance)] }

    trait :open_on_apply do
      open_on_apply { true }
      exposed_in_find { true }
      opened_on_apply_at { 2.months.ago }
    end

    trait :with_accredited_provider do
      accredited_provider { create(:provider) }
    end

    trait :with_provider_relationship_permissions do
      with_accredited_provider

      after(:build) do |_, evaluator|
        create(:provider_relationship_permissions,
               training_provider: evaluator.provider,
               ratifying_provider: evaluator.accredited_provider)
      end
    end

    trait :ucas_only do
      open_on_apply { false }
      exposed_in_find { true }
    end

    trait :with_both_study_modes do
      study_mode { :full_time_or_part_time }
    end

    trait :full_time do
      study_mode { :full_time }
    end

    trait :part_time do
      study_mode { :part_time }
    end

    trait :previous_year do
      recruitment_cycle_year { RecruitmentCycle.previous_year }
    end

    trait :previous_year_but_still_available do
      previous_year

      after(:create) do |course|
        new_course = course.dup
        new_course.recruitment_cycle_year = RecruitmentCycle.current_year
        new_course.save
      end
    end

    trait :with_valid_course_option do
      after(:create) do |course|
        create(:course_option, course: course)
      end
    end
  end
end
