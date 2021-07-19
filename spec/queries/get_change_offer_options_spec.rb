require 'rails_helper'

RSpec.describe GetChangeOfferOptions do
  include CourseOptionHelpers

  let(:ratifying_provider) { create(:provider) }
  let(:self_ratified_course) { create(:course, :open_on_apply, provider: ratifying_provider) }
  let(:externally_ratified_course) { create(:course, :open_on_apply, :with_valid_course_option, accredited_provider: ratifying_provider) }
  let(:provider_user) { create(:provider_user) }

  def service(provider_user, course)
    described_class.new(user: provider_user, current_course: course)
  end

  def set_provider_with_make_decisions(provider, make_decisions:)
    provider_user
      .provider_permissions
      .find_or_create_by(provider: provider)
      .update(make_decisions: make_decisions)
  end

  def set_org_level_make_decisions(training_provider, make_d1, ratifying_provider, make_d2)
    create(
      :provider_relationship_permissions,
      training_provider: training_provider,
      ratifying_provider: ratifying_provider,
      training_provider_can_make_decisions: make_d1,
      ratifying_provider_can_make_decisions: make_d2,
    )
  end

  describe '#make_decisions_courses' do
    it 'returns no courses if user is not associated with the course via a provider' do
      expect(service(provider_user, self_ratified_course).make_decisions_courses).to be_empty
    end

    it 'returns no courses if user lacks user-level make decisions' do
      set_provider_with_make_decisions(self_ratified_course.provider, make_decisions: false)
      expect(service(provider_user, self_ratified_course).make_decisions_courses).to be_empty
    end

    it 'returns a self-ratified course when a user has user-level make decisions' do
      set_provider_with_make_decisions(self_ratified_course.provider, make_decisions: true)
      expect(service(provider_user, self_ratified_course).make_decisions_courses)
        .to eq([self_ratified_course])
    end

    it 'returns no externally ratified courses when a training provider lacks org-level make decisions' do
      set_provider_with_make_decisions(externally_ratified_course.provider, make_decisions: true)
      expect(service(provider_user, externally_ratified_course).make_decisions_courses).to be_empty
    end

    it 'returns an externally ratified course when a training provider user has org-level make decisions' do
      set_provider_with_make_decisions(externally_ratified_course.provider, make_decisions: true)
      set_org_level_make_decisions(externally_ratified_course.provider, true,
                                   externally_ratified_course.accredited_provider, false)
      expect(service(provider_user, externally_ratified_course).make_decisions_courses)
        .to eq([externally_ratified_course])
    end

    it 'returns no externally ratified courses when a ratifying provider lacks org-level make decisions' do
      set_provider_with_make_decisions(externally_ratified_course.accredited_provider, make_decisions: true)
      expect(service(provider_user, externally_ratified_course).make_decisions_courses).to be_empty
    end

    it 'returns an externally ratified course when a ratifying provider user has org-level make decisions' do
      set_provider_with_make_decisions(externally_ratified_course.accredited_provider, make_decisions: true)
      set_org_level_make_decisions(externally_ratified_course.provider, false,
                                   externally_ratified_course.accredited_provider, true)
      expect(service(provider_user, externally_ratified_course).make_decisions_courses)
        .to eq([externally_ratified_course])
    end

    it 'externally ratified course (both providers)' do
      set_provider_with_make_decisions(externally_ratified_course.provider, make_decisions: true)
      set_provider_with_make_decisions(externally_ratified_course.accredited_provider, make_decisions: true)
      set_org_level_make_decisions(externally_ratified_course.provider, true,
                                   externally_ratified_course.accredited_provider, true)
      expect(service(provider_user, externally_ratified_course).make_decisions_courses)
        .to eq([externally_ratified_course])
    end
  end

  describe '#offerable_courses' do
    it 'returns only courses which are open on apply and exposed in find' do
      service = service(provider_user, externally_ratified_course)
      create(:course, accredited_provider: ratifying_provider)
      create(:course, accredited_provider: ratifying_provider, open_on_apply: true, exposed_in_find: false)
      allow(service).to receive(:make_decisions_courses).and_return(Course.all)
      expect(service.offerable_courses).to eq([externally_ratified_course])
    end

    it 'returns only courses that have valid sites' do
      service = service(provider_user, self_ratified_course)
      create(:course_option, course: self_ratified_course, site_still_valid: false)
      create(:course, :open_on_apply)
      allow(service).to receive(:make_decisions_courses).and_return(Course.all)
      expect(service.offerable_courses).to match_array([externally_ratified_course])
    end

    it 'returns only courses which are in the same recruitment cycle' do
      service = service(provider_user, externally_ratified_course)
      create(:course, :previous_year, accredited_provider: ratifying_provider)
      allow(service).to receive(:make_decisions_courses).and_return(Course.all)
      expect(service.offerable_courses).to eq([externally_ratified_course])
    end

    it 'returns all courses ratified by the same ratifying provider as the externally ratified course' do
      service = service(provider_user, externally_ratified_course)
      create(:course_option, course: self_ratified_course)
      create(:course, :open_on_apply)
      allow(service).to receive(:make_decisions_courses).and_return(Course.all)
      expect(service.offerable_courses).to match_array([externally_ratified_course, self_ratified_course])
    end

    it 'returns externally and self-ratified courses based on an self-ratified course' do
      service = service(provider_user, self_ratified_course)
      create(:course_option, course: self_ratified_course)
      create(:course, :open_on_apply)
      allow(service).to receive(:make_decisions_courses).and_return(Course.all)
      expect(service.offerable_courses).to match_array([externally_ratified_course, self_ratified_course])
    end
  end

  describe '#available_providers' do
    it 'only returns training providers, even if the user is associated with an accredited provider' do
      set_provider_with_make_decisions(externally_ratified_course.accredited_provider, make_decisions: true)
      set_org_level_make_decisions(externally_ratified_course.provider, true,
                                   externally_ratified_course.accredited_provider, true)

      service = service(provider_user, externally_ratified_course)
      expect(service.available_providers).to eq([externally_ratified_course.provider])
    end

    it 'does not return duplicate providers' do
      service = service(provider_user, externally_ratified_course)
      create(:course, provider: externally_ratified_course.provider)
      allow(service).to receive(:offerable_courses).and_return(Course.all)

      training_provider = externally_ratified_course.provider
      expect(service.offerable_courses.map(&:provider)).to eq([training_provider] * 2)
      expect(service.available_providers).to eq([training_provider])
    end
  end

  describe '#available_courses' do
    it 'returns offerable_courses for a specific training provider' do
      service = service(provider_user, externally_ratified_course)
      create(:course)
      allow(service).to receive(:offerable_courses).and_return(Course.all)
      expect(service.available_courses(provider: externally_ratified_course.provider))
        .to eq([externally_ratified_course])
    end
  end

  context 'study modes and sites' do
    let(:course_options) do
      [
        create(:course_option, :part_time, course: self_ratified_course),
        create(:course_option, :part_time, course: self_ratified_course),
        create(:course_option, :full_time, course: self_ratified_course),
      ]
    end

    let(:service) { described_class.new(user: provider_user, current_course: self_ratified_course) }

    before { allow(service).to receive(:offerable_courses).and_return(Course.all) }

    describe '#available_study_modes' do
      it 'returns an array of study modes' do
        course_options

        expect(service.available_study_modes(course: self_ratified_course))
          .to match_array(%w[full_time part_time])
      end

      it 'only returns study modes related to a course option whose site is still valid' do
        create(:course_option, :part_time, course: self_ratified_course)
        create(:course_option, :full_time, course: self_ratified_course, site_still_valid: false)

        expect(service.available_study_modes(course: self_ratified_course))
            .to match_array(%w[part_time])
      end
    end

    describe '#available_course_options' do
      it 'returns a collection of course options for a given course/study_mode' do
        expect(service.available_course_options(course: self_ratified_course, study_mode: 'part_time'))
          .to match_array([course_options.first, course_options.second])
      end

      it 'only returns course options whose sites are still valid' do
        valid_course_option = create(:course_option, :part_time, course: self_ratified_course)
        create(:course_option, :part_time, course: self_ratified_course, site_still_valid: false)

        expect(service.available_course_options(course: self_ratified_course, study_mode: 'part_time'))
            .to match_array([valid_course_option])
      end
    end

    describe '#available_sites' do
      it 'returns a collection of sites for a given course/study_mode' do
        expect(service.available_sites(course: self_ratified_course, study_mode: 'part_time'))
          .to match_array([course_options.first.site, course_options.second.site])
      end
    end
  end
end
