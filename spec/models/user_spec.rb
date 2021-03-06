# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  name              :string
#  email             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  password_digest   :string
#  remember_digest   :string
#  admin             :boolean          default(FALSE)
#  activation_digest :string
#  activated         :boolean          default(FALSE)
#  activated_at      :datetime
#  reset_digest      :string
#  reset_sent_at     :datetime
#

require 'rails_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
      password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:active_relationships) }
  it { should respond_to(:passive_relationships) }
  it { should respond_to(:following) }
  it { should respond_to(:followers) }
  it { should respond_to(:activated) }
  it { should respond_to(:activated_at) }
  it { should respond_to(:activation_digest) }
  it { should respond_to(:remember_digest) }
  it { should respond_to(:reset_digest) }
  it { should respond_to(:reset_sent_at) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow) }
  it { should respond_to(:unfollow) }
  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid}
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid}
  end

  describe "when name is too long" do
    before { @user.name = 'a'*51 }
    it { should_not be_valid}
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[users@foo,com user_at_foo.org example.user@foo.
       foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).to_not be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "return value of authenticate metod" do
    before { @user.save }
    let (:found_user) { User.find_by(email: @user.email) }
    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end
    describe "with invalid password" do
      let (:user_for_invalid_pwd) { found_user.authenticate("invalid") }
      it { should_not eq user_for_invalid_pwd }
      specify { expect(user_for_invalid_pwd).to be false }
    end
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should be_invalid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should be_invalid }
  end

  describe "when password is too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid}
  end

  describe "remember user" do
    before { @user.remember }
    it { expect(@user.remember_token).not_to be_blank }
    it { expect(@user.authenticated?(:remember, @user.remember_token)).to be(true) }
  end

  describe "forget user" do
    before { @user.forget }
    it { expect(@user.remember_token).to be_blank }
    it { expect(@user.authenticated?(:remember, @user.remember_token)).to be(false) }
  end

  describe "account activation" do
    describe "before activation" do
      before { @user.save! }
      it { should_not be_activated }
      it "should have the correct activation digest and token" do
        expect(@user.authenticated?(:activation, @user.activation_token)).to be(true)
      end
    end

    describe "after activation" do
      before { @user.activate }
      it { should be_activated }
      it 'sends an email' do
        expect { @user.send_activation_email }
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  describe "password reset" do
    describe "before reset" do
     specify { expect(@user.reset_token).to be_nil }
     specify { expect(@user.reset_digest).to be_nil }
    end
    describe "after reset" do
      before { @user.create_reset_digest }
      specify { expect(@user.reset_token).not_to be_nil }
      specify { expect(@user.reset_digest).not_to be_nil }
      specify { expect(@user.authenticated?(:reset, @user.reset_token)).to be(true) }
      specify { expect(@user.password_reset_expired?).to be(false) }
      it 'sends an email' do
        expect { @user.send_password_reset_email }
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

  end

  describe "micropost associations" do

    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      specify { expect(@user.feed).to include(newer_micropost) }
      specify { expect(@user.feed).to include(older_micropost) }
      specify { expect(@user.feed).to_not include(unfollowed_post) }
      specify do
        followed_user.microposts.each do |micropost|
          expect(@user.feed).to include(micropost)
        end
      end
    end

    it "should destroy associated microposts" do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow(other_user)
    end

    it { should be_following(other_user) }
    specify { expect(@user.following).to include(other_user) }

    describe "followed user" do
      specify { expect(other_user.followers).to include(@user) }
    end
    describe "and unfollowing" do
      before { @user.unfollow(other_user) }

      it { should_not be_following(other_user) }
      specify { expect(@user.following).to_not include(other_user) }
    end
  end
end
