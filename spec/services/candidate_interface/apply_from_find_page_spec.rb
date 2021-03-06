require 'rails_helper'

RSpec.describe CandidateInterface::ApplyFromFindPage do
  include TeacherTrainingPublicAPIHelper

  describe '#execute' do
    context 'When a course is in the apply database' do
      it 'sets the course_is_on_apply and course_on_find attributes to true' do
        FeatureFlag.activate('pilot_open')

        course = create(:course, open_on_apply: true, exposed_in_find: true)
        service = described_class.new(provider_code: course.provider.code,
                                      course_code: course.code)
        service.determine_whether_course_is_on_find_or_apply

        expect(service.can_apply_on_apply?).to be_truthy
        expect(service.course_on_find?).to be_truthy
        expect(service.course).to eq(course)
      end
    end

    context 'When a course is not in the apply database, but is in the find database' do
      it 'sets the course_on_find attributes to true' do
        FeatureFlag.activate('pilot_open')

        stub_teacher_training_api_course(
          provider_code: 'A999',
          course_code: 'B999',
          specified_attributes: { name: 'potions' },
        )
        stub_teacher_training_api_sites(
          provider_code: 'A999',
          course_code: 'B999',
        )
        service = described_class.new(provider_code: 'A999',
                                      course_code: 'B999')

        service.determine_whether_course_is_on_find_or_apply

        expect(service.course_on_find?).to be_truthy
        expect(service.can_apply_on_apply?).to be_falsey
        expect(service.course['name']).to eq('potions')
      end
    end
  end
end
