require "test_helper"

class MortgagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mortgage = mortgages(:one)
  end

  test "should get index" do
    get mortgages_url
    assert_response :success
  end

  test "should get new" do
    get new_mortgage_url
    assert_response :success
  end

  test "should create mortgage" do
    assert_difference("Mortgage.count") do
      post mortgages_url, params: { mortgage: { identifier: @mortgage.identifier } }
    end

    assert_redirected_to mortgage_url(Mortgage.last)
  end

  test "should show mortgage" do
    get mortgage_url(@mortgage)
    assert_response :success
  end

  test "should get edit" do
    get edit_mortgage_url(@mortgage)
    assert_response :success
  end

  test "should update mortgage" do
    patch mortgage_url(@mortgage), params: { mortgage: { identifier: @mortgage.identifier } }
    assert_redirected_to mortgage_url(@mortgage)
  end

  test "should destroy mortgage" do
    assert_difference("Mortgage.count", -1) do
      delete mortgage_url(@mortgage)
    end

    assert_redirected_to mortgages_url
  end
end
