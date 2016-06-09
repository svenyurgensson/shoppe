module Shoppe
  class Customer < ActiveRecord::Base
    EMAIL_REGEX = /\A\b[A-Z0-9\.\_\%\-\+]+@(?:[A-Z0-9\-]+\.)+[A-Z]{2,6}\b\z/i
    PHONE_REGEX = /\A[+?\d\ \-x\(\)]{7,}\z/

    self.table_name = 'shoppe_customers'

    has_many :addresses, dependent: :restrict_with_exception, class_name: 'Shoppe::Address'

    has_many :orders, dependent: :restrict_with_exception, class_name: 'Shoppe::Order'

    # Validations
    validates :email, presence: true, uniqueness: true, format: { with: EMAIL_REGEX }
    validates :phone, presence: true, format: { with: PHONE_REGEX }

    # All customers ordered by their ID desending
    scope :ordered, -> { order(id: :desc) }

    BUSINESS_ACC = [:type, :org_inn, :org_kpp, :jur_index, :jur_region,
                    :jur_city, :jur_address, :org_bank,
                    :ip_name, :ip_inn, :ip_index, :ip_region, :ip_city, :ip_address,
                    :del_index, :del_region, :del_city, :del_address].freeze

    attr_accessor *BUSINESS_ACC
    attr_accessor :password

    # The name of the customer in the format of "Company (First Last)" or if they don't have
    # company specified, just "First Last".
    #
    # @return [String]
    def name
      company.blank? ? full_name : "#{company} (#{full_name})"
    end

    def details(key)
      (business_details || {})[key.to_s]
    end

    def profile_fulfilled?
      business_details && business_details.is_a?(Hash) &&
        business_details['type'] && business_details['del_index'].present?
    end

    # The full name of the customer created by concatinting the first & last name
    #
    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w(id first_name last_name company email phone mobile) + _ransackers.keys
    end

    def self.ransackable_associations(_auth_object = nil)
      []
    end
  end
end
