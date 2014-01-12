require 'spec_helper'

describe User do
  describe 'database' do
    it {should have_db_column(:first_name).of_type(:string).with_options(null:false)}
    it {should have_db_column(:last_name).of_type(:string).with_options(null:false)}
    it {should have_db_column(:phone_number).of_type(:string).with_options(null:false)}
  end

  describe 'validations' do
    it {should validate_presence_of(:first_name)}
    it {should validate_presence_of(:last_name)}

    it {should validate_presence_of(:phone_number)}
    it {should_not have_valid(:phone_number).when("abc","!@#","123456789","12345678901")}
    it {should have_valid(:phone_number).when("1234567890")}

    it {should validate_presence_of(:password)}
    it {should validate_confirmation_of(:password)}
    it {should ensure_length_of(:password).is_at_most(128).is_at_least(6)}

    context "uniqueness validations" do
      before(:each) {FactoryGirl.create(:user)}
      it {should validate_uniqueness_of(:phone_number)}
    end
  end

  describe 'associations' do
    it {should have_many(:nags).dependent(:destroy)}
  end

  describe 'full_name method' do
    let(:user) {FactoryGirl.create(:user)}
    it "should return full name" do
      expect(user.full_name).to eq("Joe Schmoe")
    end
  end

  describe 'active? method' do
    it "should return true if the user's status is active" do
      user = FactoryGirl.create(:user)
      expect(user.active?).to be_true
    end

    it "should return false if the user's status is stopped" do
      user = FactoryGirl.create(:user, status: "stopped")
      expect(user.active?).to be_false
    end
  end

end
