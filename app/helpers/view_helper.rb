module ViewHelper
  def govuk_link_to(body, url, html_options = {}, &_block)
    html_options[:class] = prepend_css_class('govuk-link', html_options[:class])

    return link_to(url, html_options) { yield } if block_given?

    link_to(body, url, html_options)
  end

  def govuk_back_link_to(url = :back, body = 'Back')
    classes = 'app-back-link'

    if url == :back
      url = controller.request.env['HTTP_REFERER'] || 'javascript:history.back()'
      classes += ' app-back-link--fallback'
    end

    if url == 'javascript:history.back()'
      classes += ' app-back-link--no-js'
    end

    if url.is_a?(String) && url.end_with?(candidate_interface_application_form_path)
      body = 'Back to application'
    end

    link_to(body, url, class: classes)
  end

  def break_email_address(email_address)
    email_address.gsub(/@/, '<wbr>@').html_safe
  end

  def bat_contact_mail_to(name = 'becomingateacher<wbr>@digital.education.gov.uk', html_options: {})
    html_options[:class] = prepend_css_class('govuk-link', html_options[:class])

    mail_to('becomingateacher@digital.education.gov.uk', name.html_safe, html_options)
  end

  def govuk_button_link_to(body, url, html_options = {}, &_block)
    html_options = {
      class: prepend_css_class('govuk-button', html_options[:class]),
      role: 'button',
      data: { module: 'govuk-button' },
      draggable: false,
    }.merge(html_options)

    return link_to(url, html_options) { yield } if block_given?

    link_to(body, url, html_options)
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

  def boolean_to_word(boolean)
    return nil if boolean.nil?

    boolean ? 'Yes' : 'No'
  end

  def days_until_find_reopens
    (EndOfCycleTimetable.find_reopens - Time.zone.today).to_i
  end

  def provider_user_name(provider_user)
    first_name = provider_user.first_name
    last_name = provider_user.last_name
    email_address = provider_user.email_address

    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}" if first_name.present? && last_name.present?
    else
      email_address
    end
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
