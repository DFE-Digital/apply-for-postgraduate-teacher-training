module TeacherTrainingPublicAPIHelper
  def stub_teacher_training_api_providers(recruitment_cycle_year: RecruitmentCycle.current_year, specified_attributes: [])
    stub_request(
      :get,
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers",
    ).with(
      query: { page: { page: 1, per_page: 500 } },
    ).to_return(
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: build_response_body('provider_list_response.json', specified_attributes),
    )

    # Fake the error the API sends on exceeding the pagination limit
    stub_request(
      :get,
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers",
    ).with(
      query: { page: { page: 2, per_page: 500 } },
    ).to_return(
      status: 400,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: pagination_error_response,
    )
  end

  def stub_teacher_training_api_providers_with_multiple_pages(recruitment_cycle_year: RecruitmentCycle.current_year)
    [1, 2, 3].each do |page_number|
      stub_pagination_request(recruitment_cycle_year, page_number, paginated_response(page_number))
    end
  end

  def stub_teacher_training_api_courses(recruitment_cycle_year: RecruitmentCycle.current_year, provider_code:, specified_attributes: [])
    response_body = build_response_body('course_list_response.json', specified_attributes)
    stub_teacher_training_api_request("#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers/#{provider_code}/courses", response_body)
  end

  def stub_teacher_training_api_sites(recruitment_cycle_year: RecruitmentCycle.current_year, provider_code:, course_code:, specified_attributes: [], vacancy_status: 'full_time_vacancies')
    fixture_file = site_fixture(vacancy_status)
    response_body = build_response_body(fixture_file, specified_attributes)
    stub_teacher_training_api_request("#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers/#{provider_code}/courses/#{course_code}/locations?include=location_status", response_body)
  end

  def fake_api_provider(provider_attributes = {})
    api_response = JSON.parse(
      File.read(
        Rails.root.join('spec/examples/teacher_training_api/single_provider_response.json'),
      ),
      symbolize_names: true,
    )

    api_response[:data][:attributes] = api_response[:data][:attributes].merge(provider_attributes)

    TeacherTrainingPublicAPI::Provider.new(api_response[:data][:attributes])
  end

  def stubbed_recruitment_cycle_year
    @stubbed_recruitment_cycle_year || 2021
  end

private

  def stub_teacher_training_api_request(url, response_body)
    stub_request(
      :get,
      url,
    ).with(
      query: { page: { per_page: 500 } },
    ).to_return(
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: response_body,
    )
  end

  def build_response_body(fixture_file, specified_attributes = [])
    api_response = JSON.parse(
      File.read(
        Rails.root.join("spec/examples/teacher_training_api/#{fixture_file}"),
      ),
      symbolize_names: true,
    )

    if specified_attributes
      example_resource = api_response[:data].first
      new_data = specified_attributes.map do |attrs|
        specified_resource = example_resource.dup
        specified_resource[:attributes] = specified_resource[:attributes].deep_merge(attrs)
        specified_resource
      end

      api_response[:data] = new_data
    end

    api_response.to_json
  end

  def pagination_error_response
    File.read(
      Rails.root.join('spec/examples/teacher_training_api/pagination_error.json'),
    )
  end

  def paginated_response(page_number)
    JSON.parse(
      File.read(
        Rails.root.join("spec/examples/teacher_training_api/provider_pagination_response_page_#{page_number}.json"),
      ),
      symbolize_names: true,
    )
  end

  def stub_pagination_request(recruitment_cycle_year, page_number, api_response)
    stub_request(
      :get,
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers",
    ).with(
      query: { page: { page: page_number, per_page: 500 } },
    ).to_return(
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: api_response.to_json,
    )
  end

  def site_fixture(vacancy_status)
    case vacancy_status
    when 'full_time_vacancies'
      'site_list_response_with_full_time_vacancies.json'
    when 'part_time_vacancies'
      'site_list_response_with_part_time_vacancies.json'
    when 'both_full_time_and_part_time_vacancies'
      'site_list_response_with_full_time_and_part_time_vacancies.json'
    end
  end
end
