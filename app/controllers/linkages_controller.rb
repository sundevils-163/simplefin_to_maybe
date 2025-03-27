class LinkagesController < ApplicationController
  def index
    @unlinked_simplefin_accounts = Account.where(account_type: "simplefin")
                                      .where.not(id: Linkage.pluck(:simplefin_account_id).compact)

    @unlinked_maybe_accounts = Account.where(account_type: "maybe")
                                      .where.not(id: Linkage.pluck(:maybe_account_id))

    @linkages = Linkage.all
  end

  def create
    @linkage = Linkage.new(linkage_params)
    if @linkage.save
      render json: { success: true, linkage: @linkage }
    else
      render json: { success: false, errors: @linkage.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    linkage = Linkage.find(params[:id])
    linkage.update(simplefin_account_id: params[:simplefin_account_id], maybe_account_id: params[:maybe_account_id])
    render json: { success: true }
  end

  def sync
    linkage = Linkage.find(params[:id])
    # Call your backend sync logic here
    SyncService.new(linkage).perform
    render json: { success: true }
  end

  def destroy
  end

  private

  def linkage_params
    params.require(:linkage).permit(:simplefin_account_id, :maybe_account_id)
  end

end

