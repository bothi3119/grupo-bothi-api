class User < ApplicationRecord
  has_secure_password validations: false

  #Enums
  enum :role, {
    user: 0,
    admin: 1,
    super_admin: 2,
  }, default: :user

  # Scopes para filtros
  scope :by_email, ->(email) { where("email LIKE ?", "%#{email}%") if email.present? }
  scope :by_role, ->(role) { where(role: role) if role.present? }
  scope :sorted, -> { order(created_at: :desc) }
  scope :excluding_system_emails, -> { where.not(email: ["grupobothi@mailinator.com"]) }
  scope :by_text, ->(text) {
          return unless text

          where_query = <<-SQL
      users.first_name ILIKE :text OR
      users.email ILIKE :text
    SQL

          where(where_query, text: "%#{text}%")
        }

  # Validaciones
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :second_last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :password, presence: true, length: { minimum: 6 }, if: :set_password?

  def full_name
    [first_name, middle_name, last_name, second_last_name].compact.join(" ")
  end

  def locked?
    !active?
  end

  private

  def set_password?
    @set_password
  end
end
