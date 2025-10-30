class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  has_many :company_experiences, dependent: :nullify
  has_many :education, class_name: 'Education', dependent: :nullify
  has_many :certifications, dependent: :nullify
  has_many :attachments, as: :owner, dependent: :destroy
end


