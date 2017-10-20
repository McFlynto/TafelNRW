class TransportersController < ApplicationController

  def index
    @transporter = Transporter.all
  end

  def new
    @transporter = Transporter.new
  end

  def edit
    @transporter = Transporter.find(params[:id])
    @address = @transporter.address
  end

  def create
    @transporter = Transporter.new(transporter_params)
    if @transporter.save
      flash[:notice] = "Transporter wurde hinzugefügt"
      redirect_to users_path
    else
      render :new
    end
  end

  def update
    @transporter = Transporter.find(params[:id])
    if @transporter.update(transporter_params)
      flash[:notice] = "Transporter wurde bearbeitet"
      redirect_to transporters_path
    else
      render :edit
    end
  end
private
  def transporter_params
    params.require(:transporter).permit(
      :name,
      :email,
      { address_attributes:
        %i[street house_number city plz phone] }
    )
  end
end
