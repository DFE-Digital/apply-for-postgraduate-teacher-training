class OtherQualificationsReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, editable: true, deletable: true)
    @application_form = application_form
    @qualifications = CandidateInterface::OtherQualificationForm.build_all_from_application(
      @application_form,
    )
    @editable = editable
    @deletable = deletable
  end

  def other_qualifications_rows(qualification)
    [
      qualification_row(qualification),
      institution_row(qualification),
      award_year_row(qualification),
      grade_row(qualification),
    ]
  end

private

  attr_reader :application_form

  def qualification_row(qualification)
    {
      key: t('application_form.other_qualification.qualification.label'),
      value: qualification.title,
      action: (t('application_form.other_qualification.qualification.change_action') if @editable),
      change_path: (edit_other_qualification_path(qualification) if @editable),
    }
  end

  def institution_row(qualification)
    {
      key: t('application_form.other_qualification.institution.label'),
      value: qualification.institution_name,
      action: (t('application_form.other_qualification.institution.change_action') if @editable),
      change_path: (edit_other_qualification_path(qualification) if @editable),
    }
  end

  def award_year_row(qualification)
    {
      key: t('application_form.other_qualification.award_year.review_label'),
      value: qualification.award_year,
      action: (t('application_form.other_qualification.award_year.change_action') if @editable),
      change_path: (edit_other_qualification_path(qualification) if @editable),
    }
  end

  def grade_row(qualification)
    {
      key: t('application_form.other_qualification.grade.label'),
      value: qualification.grade,
      action: (t('application_form.other_qualification.grade.change_action') if @editable),
      change_path: (edit_other_qualification_path(qualification) if @editable),
    }
  end

  def edit_other_qualification_path(qualification)
    Rails.application.routes.url_helpers.candidate_interface_edit_other_qualification_path(qualification.id)
  end
end
