require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  before do
    # This code is not idiomatically correct.
    @micropost = user.microposts.build(content: "Lorem ipsum")
  end

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  specify { expect(@micropost.user).to eq user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  describe "with blank content" do
    before { @micropost.content = " " }
    it { should_not be_valid }
  end

  describe "with a content longer than 140 chars" do
    before { @micropost =  user.microposts.build(content: "a"*141) }
    it { should_not be_valid }
  end
end
