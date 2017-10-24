# Donations Controller
class DonationsController < ApplicationController
  def index
    @donator = Donator.find(params[:donator_id])
    @donations = @donator.donations
  end

  def new
    @donation = Donation.new
    @donator = Donator.find(params[:donator_id])
  end

  def create
    @donator = Donator.find(params[:donator_id])
    @donation = @donator.donations.new(donation_params)
    if @donation.save
      redirect_to donator_donations_path(@donator)
    else
      render :new
    end
  end

  def show
    @donation = Donation.find(params[:id])
    @donator = Donator.find(@donation.donator_id)
    @share = Share.new
    @share_organization = Share.where(organization: current_user.organization).first
    @shares = Share.all
  end

  def delivery
    @donation = Donation.find(params[:id])
    @donator = Donator.find(@donation.donator_id)
    @organizations = 'participating organizations'
    @transporter = Transporter.all
    @transporter.each do |trans|
      TransporterMailer.transporter_email(@donation, @donator,
                                          @organizations, trans).deliver_later
    end
    redirect_to donation_path(@donation)
  end

  def pickup
    @donation = Donation.find(params[:id])
    @shares = Share.where(donation_id: @donation)
    debugger
    puts("foo")
  end

  def collection
    @donation = Donation.find(params[:id])
    @organization = current_user.organization
    @donator = Donator.find(@donation.donator_id)
    DonatorMailer.pickup_email(@donation, @organization, @donator).deliver_later
  end

  def transport
    @donation = Donation.find(params[:id])
    @donator = Donator.find(@donation.donator_id)
    @shares = Share.where(donation_id: @donation)
    @transporter = 1
  end
private
  def donation_params
    params.require(:donation).permit(:food, :amount, :unit, :expiry_date)
  end
end
