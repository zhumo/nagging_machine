require 'spec_helper'

describe Nag do
  describe 'validations' do
    it {should validate_presence_of(:contents)}
    it {should validate_presence_of(:status)}
    it {should validate_presence_of(:user_id)}
  end
  
  describe "associations" do
    it {should belong_to(:user)}
  end

  describe 'display_status method' do
    let(:user) {FactoryGirl.create(:user)}
    let(:nag) {user.nags.create(contents: "I'm a nag")}

    it "should have an active status when the user is active" do
      expect(user.status).to eq("active")
      expect(nag.display_status).to eq("active")
    end

    it "should have a stopped status when the user is stopped" do
      user.update_attribute(:status,"stopped")
      expect(user.status).to eq("stopped")
      expect(nag.display_status).to eq("stopped")
    end

  end

  describe 'declare_done method' do
    let(:user) {FactoryGirl.create(:user)}
    let(:nag) {user.nags.create(contents: "I'm a nag")}
    it "should change the nag's status to done" do
      nag.declare_done
      expect(nag.status).to eq("done")
    end
  end
end
