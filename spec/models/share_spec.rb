require 'rails_helper'

RSpec.describe do
  let(:address) { create(:address) }
  let(:address2) { create(:address) }
  let(:address3) { create(:address) }
  let(:organization) { create(:organization, address: address) }
  let(:user) { create(:user, organization: organization) }
  let(:donator) { create(:donator, address: address2) }
  let(:transporter) { create(:transporter, address: address3) }
  let(:donation) { create(:donation, donator: donator, transporter: transporter) }
  let(:share) { create(:share, donation: donation, organization: organization) }
  let(:share2) { create(:share, donation: donation, organization: organization) }
  it 'should test the expiry date' do
    share.pick_up_date = Date.today
    donation.expiry_date = Date.today - 2.days
    share.pickup?
    expect(share.errors).not_to eq(nil)
  end

  it 'should test negative amount ' do
    share.amount = -1
    share.amount_validation?
    expect(share.errors.messages).not_to eq({})
  end

  it 'should test sum amount higher than total amount' do
    share.amount_validation?
    share2.amount = 7
    share2.amount_validation?
    expect(share.errors.messages).to eq({})
    expect(share2.errors.messages).not_to eq({})
  end

  it 'should test the amount validation for a too high share' do
    share.amount = 15
    share.amount_validation?
    expect(share.errors.messages).not_to eq({})
  end
end
