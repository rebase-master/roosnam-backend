class Certification < ApplicationRecord
  belongs_to :user
  has_many :attachments, as: :owner, dependent: :destroy

  validates :title, presence: true
  validates :issuer, presence: true
end


