FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    activated true
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end

    factory :not_active do
      activated false
    end
  end
end
