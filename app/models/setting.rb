class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  encrypts :encrypted_value, deterministic: true # Rails 7 ActiveRecord Encryption

  # Override value getter to return either encrypted or plaintext value
  def value
    encrypted? ? encrypted_value : super
  end

  # Override value setter to store in the correct column
  def value=(new_value)
    if encrypted?
      self.encrypted_value = new_value
      self[:value] = nil # Ensure plaintext column is empty
    else
      self[:value] = new_value
      self.encrypted_value = nil # Ensure encrypted column is empty
    end
  end

  # Retrieve a setting's value
  def self.get(key)
    find_by(key: key)&.value
  end

  # Set a setting's value
  def self.set(key, value, encrypted: false)
    setting = find_or_initialize_by(key: key)
    setting.encrypted = encrypted
    setting.value = value
    setting.save!
  end
end
