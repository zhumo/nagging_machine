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

  describe '#full_name' do
    let(:user) {FactoryGirl.create(:user)}
    it "should return full name" do
      expect(user.full_name).to eq("Joe Schmoe")
    end
  end

  describe '#active?' do
    context "WHEN the user's status is active" do
      it "IT should return true" do
        user = FactoryGirl.create(:user, status: "active")
        expect(user.active?).to be_true
      end
    end

    context "WHEN the user's status is not active" do
      it "should return false" do
        user = FactoryGirl.create(:user, status: "stopped")
        expect(user.active?).to be_false
      end
    end
  end

  describe "stopped? method" do
    context "WHEN the user's status is stopped" do
      it "IT should return true if the user is stopped" do
        user = FactoryGirl.create(:user, status: "stopped")

        expect(user.stopped?).to be_true
      end
    end

    context "WHEN the user's status is active" do
      it "should return false if the user is 'active' or 'awaiting confirmation'" do
        user = FactoryGirl.create(:user, status: "active")

        expect(user.stopped?).to be_false

        user.status = "awaiting confirmation"

        expect(user.stopped?).to be_false
      end
    end
  end

  describe "#stop_all_nags" do
    context "WHEN the user's status is active" do
      it "IT should change the user's status to 'stopped' and reset the job queue" do
        user = FactoryGirl.create(:user, status: "active")
        2.times {FactoryGirl.create(:nag, user: user)}
        nag = FactoryGirl.create(:nag, user: user)
        jobs_count = Sidekiq::ScheduledSet.new.clear

        user.stop_all_nags

        expect(jobs_count).to eq(Sidekiq::ScheduledSet.new.clear)
        expect(user.status).to eq("stopped")
      end
    end
    
    context "WHEN the user's status is stopped" do
      it "should not change an awaiting confirmation user's status to 'stopped'" do
        user = FactoryGirl.create(:user, status: "awaiting confirmation")

        user.stop_all_nags
        expect(user.status).to eq("awaiting confirmation")
      end
    end
  end

  describe "restart_all_nags method" do
    it "should change a stopped user's status to 'active' and reset the job queue" do
      user = FactoryGirl.create(:user, status: "active")
      jobs_count = Sidekiq::ScheduledSet.new.clear
      
      user.restart_all_nags

      expect(jobs_count).to eq(Sidekiq::ScheduledSet.new.clear)
      expect(user.status).to eq("active")
    end

    it "should not change an awaiting confirmation user's status to active'" do
      user = FactoryGirl.create(:user, status: "awaiting confirmation")

      user.restart_all_nags
      expect(user.status).to eq("awaiting confirmation")
    end
  end

  describe "confirm_phone_number" do
    user = FactoryGirl.create(:user, status: "awaiting confirmation")
  end

  describe "last_ping" do
    it "should return the last ping" do
      user = FactoryGirl.create(:user)
      2.times do 
        FactoryGirl.create(:nag, user_id: user.id)
      end

      last_nag = FactoryGirl.create(:nag, user_id: user.id, last_ping_time: Time.now + 1.hour)
      
      user.last_ping.should eq(last_nag)
    end

    it "should return nil if there is no ping" do
      user = FactoryGirl.create(:user, status: "active")

      user.last_ping.should be_nil
    end
  end

  describe "generate_confirmation_code" do
    it "should generate confirmation code and time stamp" do
      user = FactoryGirl.create(:user)

      user.generate_confirmation_code

      expect(user.confirmation_code).to be_present
      expect(user.confirmation_code_time).to be_present
    end
  end

  describe "awaiting_confirmation?" do
    it "should return true if the user's status is awaiting confirmation code" do
      user = FactoryGirl.create(:unconfirmed_user)
      expect(user.awaiting_confirmation?).to be_true
    end

  end

  describe "#full_phone_number" do
    it "should return the phone number plus the +1 extension" do
      user = FactoryGirl.create(:user)
      expect(user.full_phone_number).to eq("+1#{user.phone_number}")
    end
  end

  describe "#formatted_phone_number" do
    it "shuld return the formatted phone number" do
      user = FactoryGirl.create(:user, phone_number: "1234567890")
      expect(user.formatted_phone_number).to eq("123.456.7890")
    end
  end
end
