require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get accounts_index_url
    assert_response :success
  end

  test "should get update" do
    get accounts_update_url
    assert_response :success
  end

  test "should get delete" do
    get accounts_delete_url
    assert_response :success
  end
end
