module ViewHelper
  def govuk_link_to(body, url, html_options = {}, &_block)
    html_options[:class] = prepend_css_class('govuk-link', html_options[:class])

    return link_to(url, html_options) { yield } if block_given?

    link_to(body, url, html_options)
  end

  def govuk_back_link_to(url, body = 'Back')
    link_to(body, url, class: 'govuk-back-link govuk-!-display-none-print')
  end

  def bat_contact_mail_to(name = 'becomingateacher<wbr>@digital.education.gov.uk', html_options: {})
    html_options[:class] = prepend_css_class('govuk-link', html_options[:class])

    mail_to('becomingateacher@digital.education.gov.uk', name.html_safe, html_options)
  end

  def govuk_button_link_to(body, url, html_options = {})
    html_options[:class] = prepend_css_class('govuk-button', html_options[:class])

    link_to(body, url, role: 'button', class: html_options[:class], 'data-module': 'govuk-button', draggable: false)
  end

  def submitted_at_date
    dates = ApplicationDates.new(@application_form)
    dates.submitted_at.to_s(:govuk_date).strip
  end

  def respond_by_date
    dates = ApplicationDates.new(@application_form)
    dates.reject_by_default_at.to_s(:govuk_date).strip if dates.reject_by_default_at
  end

  def formatted_days_remaining
    dates = ApplicationDates.new(@application_form)
    pluralize(dates.days_remaining_to_edit, 'day')
  end

  def title_with_error_prefix(title, error)
    "#{t('page_titles.error_prefix') if error}#{title}"
  end

  def title_with_success_prefix(title, success)
    "#{t('page_titles.success_prefix') if success}#{title}"
  end

  def edit_by_date
    dates = ApplicationDates.new(@application_form)
    dates.edit_by.to_s(:govuk_date).strip
  end

  def format_months_to_years_and_months(number_of_months)
    duration_parts = ActiveSupport::Duration.build(number_of_months.months).parts

    if duration_parts[:years].positive? && duration_parts[:months].positive?
      "#{pluralize(duration_parts[:years], 'year')} and #{pluralize(duration_parts[:months], 'month')}"
    elsif duration_parts[:years].positive?
      pluralize(duration_parts[:years], 'year')
    else
      pluralize(number_of_months, 'month')
    end
  end

  def days_to_respond_to(application_choice)
    (application_choice.reject_by_default_at.to_date - Date.current).to_i
  end

private

  def prepend_css_class(css_class, current_class)
    if current_class
      current_class.prepend("#{css_class} ")
    else
      css_class
    end
  end
end
