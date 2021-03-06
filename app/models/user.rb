class User < ActiveRecord::Base
  has_many :meetups
  has_many :attendances, dependent: :destroy
  has_many :attend_meetups, through: :attendances, source: :meetup
  has_many :microposts
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  before_save { self.email = email.downcase }
  before_create :create_remember_roken

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # validation
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true

  has_secure_password
  validates :password, length: { minimum: 6 }

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  # attend meetup
  def attend_meetup!(meetup)
    attendances.create!(meetup_id: meetup.id)
  end

  # cancel to attend meetup
  def cancel_meetup!(meetup)
    attendances.find_by(meetup_id: meetup.id).destroy
  end

  # check attendance
  def attend_meetup?(meetup)
    attendances.find_by(meetup_id: meetup.id)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

  private
    def create_remember_roken
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
