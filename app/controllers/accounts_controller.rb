class AccountsController < ApplicationController
  before_action :set_account, only: [:destroy]

  def index
  end

  def destroy
    @account.destroy
    redirect_to accounts_path
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
