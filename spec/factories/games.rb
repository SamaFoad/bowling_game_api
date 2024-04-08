FactoryBot.define do
  factory :game do
    id { 7 }
    status { 'started' }
    created_at { DateTime.now.to_s(:db) }
    updated_at { DateTime.now.to_s(:db) }
  end
end
