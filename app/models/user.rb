class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable,
  #:recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable,
         :trackable

  validates_confirmation_of :password
  validates_length_of :password, within: 6..128, allow_nil: true

  validates_format_of :phone_number, with: /\A\d{10}\z/, message: "must be a ten-digit number"
  validates_presence_of :phone_number
  validates_uniqueness_of :phone_number

  validates_presence_of :first_name
  validates_presence_of :last_name

  has_many :nags, inverse_of: :user, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_phone_number
    "+1#{phone_number}"
  end

  def active?
    status == "active"
  end

  def stopped?
    status == "stopped"
  end

  def stop_all_nags
    update_attribute(:status, "stopped") if status == "active"
  end

  def restart_all_nags
    update_attribute(:status, "active") if status == "stopped"
  end

  def confirm_phone_number
    update_attributes(confirmation_code: nil, confirmation_code_time: nil, status: "active")
  end

  def last_ping
    nags.order(:last_ping_time).first
  end
  
  def generate_confirmation_code
    update_attributes(confirmation_code: sprintf("%04d",rand(10 ** 4)), confirmation_code_time: Time.now)
  end

  def awaiting_confirmation?
    status == "awaiting confirmation"
  end

end
