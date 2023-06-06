class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # has_one_attached :photo

  validates :name, presence: true

  # after_validation :set_photo

  # private

  # def set_photo
  #   unless photo.attached?
  #     file = File.open("#{Rails.root}/app/assets/images/pigeon.png")
  #     photo.attach(io: file, filename: "#{id}.png", content_type: "image/png")
  #   end
  # end
end
