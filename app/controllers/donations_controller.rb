# Donations Controller
class DonationsController < ApplicationController
  before_action :require_login, only:[:show ,:delivery, :transport, :confirm_transport ]
  def index
    @donator = Donator.find(params[:donator_id])
    @donations = @donator.donations
  end

  def new
    @donator = Donator.find(params[:donator_id])
    @donation = @donator.donations.new
  end

  def edit
    @donation = Donation.find(params[:id])
    @donator = @donation.donator
  end

  def update
    @donation = Donation.find(params[:id])
    @donator = @donation.donator

    if @donation.update(donation_params)
      redirect_to donator_donations_path(@donator)
    else
      render :edit
    end
  end

  def create
    @donator = Donator.find(params[:donator_id])
    @donation = @donator.donations.new(donation_params)
    if @donation.save
      DonationEmailService.new(@donation, @donator).send_donation_email
      redirect_to thank_you_donator_path(@donator)
    else
      render :new
    end
  end

  def update_transport
    @donation = Donation.find(params[:id])
    if @donation.update(transporter_donation_params)
      redirect_to transport_donation_path(@donation)
    else
      render :transport
    end
  end

  def show
    @donation = Donation.find(params[:id])
    @donator = @donation.donator
    @share = Share.new
    @share_organization = @donation.shares.where(organization: current_user.organization).first
    @shares = @donation.shares.all
  end

  def show_donator
    @donation = Donation.find(params[:id])
    @donator = @donation.donator
    @shares = @donation.shares.all
  end

  def delivery
    @donation = Donation.find(params[:id])
    @donator = @donation.donator
    @donation.update(ordered: true)
    ConfirmTransportService.new(@donation, @shares, @donator).send_transporter_email
    redirect_to thank_you_donation_path(@donation)
  end

  def thank_you
    @donation = Donation.find(params[:id])
    @shares = @donation.shares.all
  end

  def transport
    @donation = Donation.find(params[:id])
    @donator = @donation.donator
    @shares = @donation.shares.where(pick_up: false)
    set_transporter_token
    find_transporter
    unless transporter_authenticated?
      redirect_to root_path
    end
  end

  def confirm_transport
    @donation = Donation.find(params[:id])
    @donator = @donation.donator
    @shares = @donation.shares.where(pick_up: false)
    set_transporter_token
    find_transporter
    @donation.update(donation_params)
    @donation.transporter = @transporter
    @donation.save
    ConfirmTransportService.new(@donation, @shares, @donator).send_transport_confirmation
    redirect_to transport_donation_path(@donation, transporter_hash: @transporter.transporter_hash)
  end

  private

  def donation_params
    params.require(:donation).permit(:food, :amount, :unit, :expiry_date , :delivery_date, :confirmed)
  end

  def transporter_donation_params
    params.require(:donation).permit(:delivery_date)
  end

  def set_transporter_token
    if params[:transporter_hash].present?
      @transporter_token = params.fetch(:transporter_hash, nil)
      session[:transporter_hash] = @transporter_token
    else
      @transporter_token = session.fetch(:transporter_hash, nil)
    end
  end

  helper_method :transporter_authenticated?
  def transporter_authenticated?
    @transporter.present? && @transporter_token.present?
  end

  helper_method :find_transporter
  def find_transporter
    @transporter ||= Transporter.find_by_transporter_hash(@transporter_token)
  end
end
