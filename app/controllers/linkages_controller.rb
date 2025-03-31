class LinkagesController < ApplicationController
  before_action :set_linkage, only: [:sync, :destroy]
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
      #Rails.logger.info "YES SAVE"
      #if create_linkage_in_maybe_database()
      redirect_to linkages_path, notice: 'Linkage created successfully.'
      #else
      #  Rails.logger.error 'Failed to create linkage1'
      #  render :index, alert: 'Failed to create linkage1'
      #end
    else
      Rails.logger.error 'Failed to create linkage'
      render :index, alert: 'Failed to create linkage'
    end
  end

  def destroy
    @linkage = Linkage.find(params[:id])
    @linkage.destroy
    redirect_to linkages_path, notice: 'Linkage deleted successfully.'
  end

  def sync
    @linkage.update(sync_status: :pending)
    SyncLinkageJob.perform_later(@linkage)
    redirect_to linkages_path, notice: 'Sync started successfully.'
  end

  def run_all_syncs
    Linkage.find_each do |linkage|
      linkage.sync
    end

    redirect_to linkages_path, notice: 'All syncs started successfully.'
  end

  def sync_status
    linkage = Linkage.find(params[:id])
    Rails.logger.info "Sync Status: #{linkage.sync_status}"
    render json: { sync_status: linkage.sync_status, last_sync: linkage.last_sync }
  end

  private

  #def create_linkage_in_maybe_database()
  #
  #  maybe_client = MaybeClientService.connect
  #
  #  if maybe_client
  #    @maybe_account = Account.find_by(id: @linkage.maybe_account_id)
  #    if @maybe_account
  #      #maybe_client.new_simplefin_import(@maybe_account, @linkage.simplefin_id_sanitized)  #dont think this is needed at all.. we store the in our postgres now
  #      return true
  #    else
  #      Rails.logger.error "Maybe account not found for ID: #{@linkage.maybe_account_id}"
  #    end
  #  else
  #    Rails.logger.error "Could not connect to Maybe database"
  #  end
  #  return false
  #end

  def set_linkage
    @linkage = Linkage.find(params[:id])
  end

  def linkage_params
    # First, permit the required parameters
    permitted_params = params.require(:linkage).permit(:simplefin_account_id, :maybe_account_id)
  
    ## Sanitize simplefin_account_id by removing the "ACT-" prefix (if it exists)
    #if permitted_params[:simplefin_account_id].present?
    #  sanitized_id = permitted_params[:simplefin_account_id].sub(/^ACT-/, "")
    #  # Add the sanitized value as a new key 'simplefin_id_sanitized'
    #  permitted_params[:simplefin_id_sanitized] = sanitized_id
    #end

    Rails.logger.info "Sanitized params: #{permitted_params.inspect}"
  
    # Return the modified parameters (with the new sanitized value)
    permitted_params
  end
  
end
