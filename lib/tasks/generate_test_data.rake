task generate_test_data: :environment do
  GenerateTestData.new.generate
end
