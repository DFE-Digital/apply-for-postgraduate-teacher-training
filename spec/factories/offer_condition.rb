FactoryBot.define do
  factory :offer_condition do
    offer

    text { 'Evidence of being cool' }
    status { 'pending' }
  end
end
