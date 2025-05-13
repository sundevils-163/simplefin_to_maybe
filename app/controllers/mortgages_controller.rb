class MortgagesController < ApplicationController
  before_action :set_mortgage, only: [ :sync, :destroy, :update ]
  skip_before_action :verify_authenticity_token, only: [:run_all_syncs]  #let the background job invoke without csrf issues

  def index
    # Fetch existing mortgages
    @mortgages = Mortgage.all

    # init a new one for our form
    @mortgage = Mortgage.new

    # Fetch maybe accounts that aren't linked yet
    @maybe_accounts = Account.where(account_type: 'maybe').where(accountable_type: 'Loan')
    @unused_maybe_accounts = @maybe_accounts.where.not(id: Mortgage.pluck(:maybe_account_id))
  end

  def create
    @mortgages = Mortgage.all

    # Create new mortgage
    @mortgage = Mortgage.new(mortgage_params)
    if @mortgage.save
      redirect_to mortgages_path, notice: 'Mortgage created successfully.'
    else
      Rails.logger.error 'Failed to create mortgage'
      render :index, alert: 'Failed to create mortgage'
    end
  end

  def update
    if @mortgage.update(mortgage_params)
      redirect_to mortgages_path, notice: 'Linkage updated successfully.'
    else
      render :index, alert: 'Failed to update mortgage'
    end
  end

  def destroy
    @mortgage.destroy!
  redirect_to mortgages_path, notice: 'Linkage deleted successfully.'
  end

  def sync
    if @mortgage.enabled?
      MortgageTransactionJob.perform_later(@mortgage)
      redirect_to mortgages_path, notice: 'Sync started successfully.'
    end
  end

  def run_all_syncs
    Rails.logger.info "Starting all Mortgage Syncs!"
    Mortgage.find_each do |mortgage|
      mortgage.sync
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mortgage
      @mortgage = Mortgage.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mortgage_params
      if action_name == 'create'
        permitted_params = params.require(:mortgage).permit(:maybe_account_id, :apr, :escrow_payment, :principal_payment, :day_of_month)
      elsif action_name == 'update'
        permitted_params = params.require(:mortgage).permit(:enabled)
        permitted_params[:enabled] = (permitted_params[:enabled] == "on")  # on/off to true/false
      end

      Rails.logger.info "Sanitized params: #{permitted_params.inspect}"

      permitted_params
  end
end
