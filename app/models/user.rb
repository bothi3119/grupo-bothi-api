# app/models/user.rb
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
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  def full_name
    [first_name, middle_name, last_name, second_last_name].compact.join(" ")
  end

  def locked?
    !active?
  end

  # Method to update password with confirmation
  def update_password(current_password, new_password, new_password_confirmation)
    errors.add(:current_password, "es incorrecta") unless authenticate(current_password)
    errors.add(:new_password, "no puede estar vacía") if new_password.blank?
    errors.add(:new_password, "debe tener al menos 6 caracteres") if new_password.present? && new_password.length < 6
    errors.add(:new_password_confirmation, "no coincide con la nueva contraseña") if new_password != new_password_confirmation

    return false unless errors.empty?

    update(password: new_password)
  end

  # Method to reset password with token validation
  def reset_password_with_token(token, new_password, new_password_confirmation)
    errors.add(:new_password, "no puede estar vacía") if new_password.blank?
    errors.add(:new_password, "debe tener al menos 6 caracteres") if new_password.present? && new_password.length < 6
    errors.add(:new_password_confirmation, "no coincide con la nueva contraseña") if new_password != new_password_confirmation

    return false unless errors.empty?

    update(password: new_password)
  end

  private

  def password_required?
    # Require password for new records or when password is being changed
    new_record? || !password.nil?
  end
end
