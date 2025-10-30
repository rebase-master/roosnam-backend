class ClientProject < ApplicationRecord
  belongs_to :company_experience

  has_many :client_reviews, dependent: :destroy
  has_many :attachments, as: :owner, dependent: :destroy

  validates :name, presence: true
end


