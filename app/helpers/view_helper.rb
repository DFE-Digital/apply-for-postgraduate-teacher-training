module ViewHelper
  def govuk_back_link_to(url = :back, body = 'Back')
    classes = 'govuk-!-display-none-print'

    url = back_link_url if url == :back

    if url.is_a?(String) && url.end_with?(candidate_interface_application_form_path)
      body = 'Back to application'
    end

    render GovukComponent::BackLink.new(
      text: body,
      href: url,
      classes: classes,
    )
  end

  def breadcrumbs(breadcrumbs)
    render GovukComponent::Breadcrumbs.new(
      breadcrumbs: breadcrumbs,
      hide_in_print: true,
    )
  end

  def break_email_address(email_address)
    email_address.gsub(/@/, '<wbr>@').html_safe
  end

  def bat_contact_mail_to(name = 'becomingateacher<wbr>@digital.education.gov.uk', html_options: {})
    govuk_mail_to('becomingateacher@digital.education.gov.uk', name.html_safe, html_options)
  end

  def submitted_at_date
    dates = ApplicationDates.new(@application_form)
    return if dates.submitted_at.nil?

    dates.submitted_at.to_s(:govuk_date).strip
  end

  def title_with_error_prefix(title, error)
    "#{t('page_titles.error_prefix') if error}#{title}"
  end

  def title_with_success_prefix(title, success)
    "#{t('page_titles.success_prefix') if success}#{title}"
  end

  def format_months_to_years_and_months(number_of_months)
    duration_parts = ActiveSupport::Duration.build(number_of_months.months).parts

    if duration_parts[:years] && duration_parts[:months]
      "#{pluralize(duration_parts[:years], 'year')} and #{pluralize(duration_parts[:months], 'month')}"
    elsif duration_parts[:years]
      pluralize(duration_parts[:years], 'year')
    else
      pluralize(number_of_months, 'month')
    end
  end

  def time_is_today_or_tomorrow?(time)
    time.between?(Time.zone.now.beginning_of_day, Time.zone.tomorrow.end_of_day)
  end

  def time_today_or_tomorrow(time)
    unless time_is_today_or_tomorrow?(time)
      raise "#{time} was expected to be today or tomorrow, but is not"
    end

    if time.to_date == Date.tomorrow
      "#{time.to_s(:govuk_time)} tomorrow"
    else
      time.to_s(:govuk_time).to_s
    end
  end

  def date_and_time_today_or_tomorrow(time)
    unless time_is_today_or_tomorrow?(time)
      raise "#{time} was expected to be today or tomorrow, but is not"
    end

    date_and_time = time.to_s(:govuk_date_and_time)
    today_or_tomorrow = time.to_date == Date.tomorrow ? 'tomorrow' : 'today'

    "#{today_or_tomorrow} (#{date_and_time})"
  end

  def days_until(date)
    days = (date - Date.current).to_i
    if days.zero?
      'less than 1 day'
    else
      pluralize(days, 'day')
    end
  end

  def boolean_to_word(boolean)
    return nil if boolean.nil?

    boolean ? 'Yes' : 'No'
  end

  def percent_of(numerator, denominator)
    numerator.to_f / denominator * 100.0
  end

  def formatted_percentage(count, total)
    return '-' if total.zero?

    percentage = percent_of(count, total)
    precision = (percentage % 1).zero? ? 0 : 2
    number_to_percentage(percentage, precision: precision)
  end

  def protect_against_mistakes
    if session[:confirmed_environment_at] && session[:confirmed_environment_at] > 5.minutes.ago
      yield
    else
      govuk_link_to 'Confirm environment to make changes', support_interface_confirm_environment_path(from: request.fullpath)
    end
  end

private

  def back_link_url
    referer = controller.request.env['HTTP_REFERER']

    if !referer
      service_link
    else
      referer_host = URI(referer).host
      if referer_host.present? && referer_host != request.host
        service_link
      else
        referer
      end
    end
  end
end
