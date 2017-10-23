class Organization < ApplicationRecord
  has_one :address, as: :addressable
  accepts_nested_attributes_for :address
  has_many :donations, through: :donation_organizations
end
