module GcseQualificationHelper
  def select_gcse_qualification_type_options
    option = Struct.new(:id, :label)

    t('application_form.gcse.qualification_types').map { |id, label| option.new(id, label) }
  end

  def heading_for_gcse_edit_type(subject)
    t("gcse_edit_type.page_titles.#{subject}")
  end

  def hint_for_gcse_edit_grade(subject, qualification_type)
    subject = subject == 'science' ? 'science' : 'other'
    if I18n.exists?("gcse_edit_grade.hint.#{subject}.#{qualification_type}")
      t("gcse_edit_grade.hint.#{subject}.#{qualification_type}")
    end
  end
end
