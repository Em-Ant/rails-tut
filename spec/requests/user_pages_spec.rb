require 'rails_helper'
require 'support/utilities.rb'

describe "User pages" do

  subject { page }

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before (:each) do
      sign_in user
      visit users_path
    end
    it { should have_title('All users') }
    it { should have_selector('h1', text: 'All users') }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }
      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_link(user.name, href: user_path(user))
        end
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    it { should have_selector('h1', text: user.name) }
    it { should have_title(user.name) }
  end

  describe "signup" do
    before do
      clear_emails
      visit signup_path
    end
    let(:submit) { "Create my account" }

    it { should have_selector('h1', :text => 'Sign up') }
    it { should have_title(full_title("Sign up")) }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.to_not change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end
      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it "should redirect to homepage" do
          expect(page).to have_link('Sign in')
          expect(page).to have_selector("h1", text: "Welcome to the Sample App")
        end
        it "should show info about activation email" do
          expect(page).to have_selector('div.alert.alert-info',
            text: 'Please check your email to activate your account')
        end

        specify "user should not be activated" do
          expect(user.activated?).to be(false)
        end

        describe "when using a wrong activation link" do
          before { visit edit_account_activation_url('wrong_token', email: user.email) }
          it "should redirect to root url" do
            expect(page).to have_link('Sign in')
            expect(page).to have_selector("h1", text: "Welcome to the Sample App")
          end
          it "should show an Error alert" do
            expect(page).to have_selector('div.alert.alert-danger', text: 'Invalid activation link')
          end
        end

        describe "after clicking the correct activation link" do
          before do
            open_email(user.email)
            current_email.click_link 'Activate'
          end
          it "should redirect to the user's page" do
            expect(page).to have_link('Sign out')
            expect(page).to have_title(user.name)
            expect(page).to have_selector('h1', text: user.name)
          end
          it "should show a Success alert" do
            expect(page).to have_selector('div.alert.alert-success', text: 'Account activated!')
          end
        end
      end
    end
  end

  describe "password_reset" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      clear_emails
      visit new_password_reset_path
    end

    describe "with valid email" do
      before do
        fill_in "Email", with: user.email
        click_button "Submit"
      end
      it "should redirect to homepage" do
        expect(page).to have_link('Sign in')
        expect(page).to have_selector("h1", text: "Welcome to the Sample App")
      end
      it "should show an Info alert" do
        expect(page).to have_selector('div.alert.alert-info', text: 'Email sent with password reset instructions')
      end
      describe "when using a wrong reset link" do
        before { visit edit_password_reset_url('wrong_token', email: user.email) }
        it "should redirect to root url" do
          expect(page).to have_link('Sign in')
          expect(page).to have_selector("h1", text: "Welcome to the Sample App")
        end
      end
      describe "after clicking the correct activation link" do
        before do
          open_email(user.email)
          current_email.click_link 'Reset password'
        end
        it { should have_link('Sign in') }
        it { should have_selector("h1", text: "Reset password") }
        describe "with new password and matching confirmation" do
          before do
            @digest_before = User.find_by(email: user.email).password_digest
            fill_in "Password",     with: "new_pwd"
            fill_in "Confirmation", with: "new_pwd"
            click_button "Update password"
          end
          # Log in user, redirect to user's page, and show success alert
          it { should have_link('Sign out') }
          it { should have_title(user.name) }
          it { should have_selector('h1', text: user.name) }
          it { should have_selector('div.alert.alert-success', text: 'Password has been reset.') }

          # Password changed
          let(:digest_after) { User.find_by(email: user.email).password_digest }
          specify { expect(digest_after).not_to eq(@digest_before) }
        end
        describe "with invalid data" do
          before do
            @digest_before = User.find_by(email: user.email).password_digest
            fill_in "Password",     with: "new_pwd"
            fill_in "Confirmation", with: "unmatched"
            click_button "Update password"
          end
          # Redirect to reset password, and show errors alert
          it { should have_link('Sign in') }
          it { should have_selector('h1', text: "Reset password") }
          it { should have_selector('div.alert.alert-danger', text: 'The form contains 1 error.') }

          # Password not changed
          let(:digest_after) { User.find_by(email: user.email).password_digest }
          specify { expect(digest_after).to eq(@digest_before) }
        end
      end
    end
    describe "with invalid email" do
      before do
        fill_in "Email", with: "invalid_email@test.cxm"
        click_button "Submit"
      end
      # Redirect to forgot password, and show error alert
      it { should have_link('Sign in') }
      it { should have_selector('h1', text: "Forgot password") }
      it { should have_selector('div.alert.alert-danger', text: 'Email address not found') }
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end
    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirmation", with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end
      specify { expect(user.reload).not_to be_admin }
    end
  end
end
