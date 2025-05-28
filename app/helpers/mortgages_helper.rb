module MortgagesHelper
  def escrow_information
    information = []
    information << "Monthly Escrow payment; Enter '0' to not insert an escrow-related transaction"
    return information.join("\n")
  end

  def exclude_information
    information = []
    information << "Select Exclude if you wish the inserted transactions to be marked as 'One-Time' in Maybe"
    return information.join("\n")
  end
end
