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
    let(:nag) {FactoryGirl.create(:nag, user_id: user.id)}

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
    let(:nag) {FactoryGirl.create(:nag, user_id: user.id)}
    it "should change the nag's status to done" do
      nag.declare_done
      expect(nag.status).to eq("done")
    end
  end

  describe ".populate_sidekiq" do
    it "should send a ping time to NagWorker with the nag id" do
      user_1 = FactoryGirl.create(:user)

      2.times do |n|
        FactoryGirl.create(:nag, user_id: user_1.id)
      end
      
      first_nag = FactoryGirl.create(:nag, user_id: user_1.id)

      expect(NagWorker).to receive(:perform_at).with(first_nag.next_ping_time, first_nag.id)
      
      Nag.populate_sidekiq
    end
  end

  describe ".first_to_be_pinged" do
    it "should return the earliest-timed nag" do
      user_1 = FactoryGirl.create(:user)
      user_2 = FactoryGirl.create(:user)

      2.times do |n|
        FactoryGirl.create(:nag, user_id: user_1.id)
        FactoryGirl.create(:nag, user_id: user_2.id)
      end
      
      first_nag = FactoryGirl.create(:nag, user_id: user_1.id)

      expect(Nag.first_nag_to_be_pinged).to eq(first_nag)
    end
  end

  describe "#generate_next_ping_time" do
    it "should return a randomly generated time in the future" do
      @nag = FactoryGirl.create(:nag)

      old_time = @nag.next_ping_time

      @nag.generate_next_ping_time
      @nag.reload

      @nag.next_ping_time.should > old_time
    end
  end

  describe "create a new nag" do
    it "should randomly generate a next_ping_time upon create" do
      nag = FactoryGirl.create(:nag)
      expect(nag.next_ping_time).to be_present
    end
  end
end
