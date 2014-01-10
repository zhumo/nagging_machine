class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable,
  #:recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable,
         :trackable

  validates_presence_of :password
  validates_confirmation_of :password
  validates_length_of :password, within: 6..128

  validates_format_of :phone_number, with: /\A\d{10}\z/, message: "must be a ten-digit number"
  validates_presence_of :phone_number
  validates_uniqueness_of :phone_number

  validates_presence_of :first_name
  validates_presence_of :last_name

  has_many :nags, inverse_of: :user

  def full_name
    "#{first_name} #{last_name}"
  end
end
