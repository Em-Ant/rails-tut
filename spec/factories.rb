FactoryGirl.define do
  factory :user do
    name      "John Doe"
    email     "test@test.com"
    password  "foobar"
    password_confirmation "foobar"
  end
end
