desc 'Set up your local development environment with data from Find'
task setup_local_dev_data: %i[environment copy_feature_flags_from_production sync_dev_providers_and_open_courses generate_test_applications] do
  puts 'Creating a provider-only user with DfE Sign-in UID `dev-provider` and email `provider@example.com`...'
  ProviderUser.find_or_create_by!(dfe_sign_in_uid: 'dev-provider', email_address: 'provider@example.com') do |u|
    u.providers = [ApplicationChoice.first.provider]
  end

  puts 'Creating a support & provider user with DfE Sign-in UID `dev-support` and email `support@example.com`...'
  ProviderUser.find_or_create_by!(dfe_sign_in_uid: 'dev-support', email_address: 'support@example.com') do |u|
    u.providers = [ApplicationChoice.first.provider]
  end
  SupportUser.find_or_create_by!(dfe_sign_in_uid: 'dev-support', email_address: 'support@example.com')

  ProviderPermissions.update_all(manage_users: true) if FeatureFlag.active?('provider_add_provider_users')
end

desc 'Sync some pilot-enabled providers and open all their courses'
task sync_dev_providers_and_open_courses: :environment do
  puts 'Syncing data from Find...'

  provider_codes = HostingEnvironment.review? ? %w[1N1] : %w[1N1 2LR C58 C85]
  provider_codes.each do |code|
    SyncProviderFromFind.call(provider_code: code, sync_courses: true)
  end

  puts 'Making all the courses open on Apply...'
  Provider.all.each do |provider|
    OpenProviderCourses.new(provider: provider).call
  end
end

desc 'Copy feature flags from production to your local dev env'
task copy_feature_flags_from_production: :environment do
  flags = JSON.parse(HTTP.get('https://www.apply-for-teacher-training.education.gov.uk/integrations/feature-flags')).fetch('feature_flags')

  puts 'Synchronising feature flags with production...'

  FeatureFlag::FEATURES.each do|f|
    if flags.dig(f, 'active')
      puts "+ #{f}"
      FeatureFlag.activate(f)
    else
      puts "- #{f}"
      FeatureFlag.deactivate(f)
    end
  end
end
