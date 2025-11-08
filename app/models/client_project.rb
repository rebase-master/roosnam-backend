class ClientProject < ApplicationRecord
  belongs_to :user
  has_many :client_reviews, dependent: :destroy
  has_and_belongs_to_many :skills

  has_many :client_reviews, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  validates :name, presence: true
end


