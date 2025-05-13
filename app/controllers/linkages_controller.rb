class LinkagesController < ApplicationController
  before_action :set_linkage, only: [:sync, :destroy, :update]
  skip_before_action :verify_authenticity_token, only: [:run_all_syncs]  #let the background job invoke without csrf issues

  def index
    # Fetch existing linkages
    @linkages = Linkage.all

    # init a new one for our form
    @linkage = Linkage.new

    # Fetch simplefin and maybe accounts that aren't linked yet
    @simplefin_accounts = Account.where(account_type: 'simplefin').where.not(id: Linkage.pluck(:simplefin_account_id))
    @maybe_accounts = Account.where(account_type: 'maybe').where.not(id: Linkage.pluck(:maybe_account_id))
  end

  def create
    @linkages = Linkage.all

    # Create new linkage
    @linkage = Linkage.new(linkage_params)
    if @linkage.save
      redirect_to linkages_path, notice: 'Linkage created successfully.'
    else
      Rails.logger.error 'Failed to create linkage'
      render :index, alert: 'Failed to create linkage'
    end
  end

  def update
    if @linkage.update(linkage_params)
      redirect_to linkages_path, notice: 'Linkage updated successfully.'
    else
      render :index, alert: 'Failed to update linkage'
    end
  end

  def destroy
    @linkage.destroy
    redirect_to linkages_path, notice: 'Linkage deleted successfully.'
  end

  def sync
    if @linkage.enabled?
      @linkage.update(sync_status: :pending)
      SyncLinkageJob.perform_later(@linkage)
      redirect_to linkages_path, notice: 'Sync started successfully.'
    end
  end

  def run_all_syncs
    Rails.logger.info "Starting all Syncs!"
    Linkage.find_each do |linkage|
      linkage.sync
    end
  end

  def sync_status
    linkage = Linkage.find(params[:id])
    Rails.logger.info "Sync Status: #{linkage.sync_status}"
    render json: { sync_status: linkage.sync_status, last_sync: linkage.last_sync }
  end

  private

  def set_linkage
    @linkage = Linkage.find(params[:id])
  end

  def linkage_params
    if action_name == 'create'
      permitted_params = params.require(:linkage).permit(:simplefin_account_id, :maybe_account_id)
    elsif action_name == 'update'
      permitted_params = params.require(:linkage).permit(:enabled)
      permitted_params[:enabled] = (permitted_params[:enabled] == "on")  # on/off to true/false
    end

    Rails.logger.info "Sanitized params: #{permitted_params.inspect}"

    permitted_params
  end
  
end
