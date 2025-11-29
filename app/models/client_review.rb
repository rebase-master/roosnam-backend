class ClientReview < ApplicationRecord
  belongs_to :client_project
  belongs_to :user
  validates :reviewer_name, presence: true
  validates :review_text, presence: true
  validates :rating, inclusion: { in: 1..5, message: "must be in 1..5" }, allow_nil: true

  before_validation :set_default_user, on: :create

  scope :positive, -> { where('rating >= ?', 4) }
  scope :with_rating, -> { where.not(rating: nil) }

  def reviewer_display_name
    if reviewer_company.present?
      "#{reviewer_name}, #{reviewer_position} at #{reviewer_company}"
    elsif reviewer_position.present?
      "#{reviewer_name}, #{reviewer_position}"
    else
      reviewer_name
    end
  end

  private

  def set_default_user
    self.user ||= User.first
  end
end
