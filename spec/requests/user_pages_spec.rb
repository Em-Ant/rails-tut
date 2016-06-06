require 'rails_helper'
require 'support/utilities.rb'

describe "User pages" do

  subject { page }

  describe "Signup page" do
    before {visit signup_path}
    it { should have_selector('h1', :text => 'Sign up') }
    it { should have_title(full_title("Sign up")) }
  end
end
