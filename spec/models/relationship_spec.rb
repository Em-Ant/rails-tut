require 'rails_helper'

describe Relationship do

  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:active_relationship) { follower.active_relationships.build(followed_id: followed.id) }

  subject { active_relationship }

  it { should be_valid }

  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    specify { expect(active_relationship.follower).to eq follower }
    specify { expect(active_relationship.followed).to eq followed }
  end
  describe "when followed id is not present" do
    before { active_relationship.followed_id = nil }
    it { should_not be_valid }
  end

  describe "when follower id is not present" do
    before { active_relationship.follower_id = nil }
    it { should_not be_valid }
  end
end
