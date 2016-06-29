module Shoppe
  class PasswordReset < ActiveRecord::Base
    belongs_to :customer, class_name: 'Shoppe::Customer'
    before_create :generate_unique_token
    delegate :email, to: :customer, allow_nil: true

    def to_param
      token
    end

    private

    def generate_unique_token
      self.token = generate_token

      while Shoppe::PasswordReset.exists?(token: self.token)
        self.token = generate_token
      end
    end

    def generate_token
      SecureRandom.hex(20).encode('UTF-8')
    end
  end
end
