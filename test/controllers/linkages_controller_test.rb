require "test_helper"

class LinkagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get linkages_index_url
    assert_response :success
  end

  test "should get create" do
    get linkages_create_url
    assert_response :success
  end

  test "should get destroy" do
    get linkages_destroy_url
    assert_response :success
  end

  test "should get sync" do
    get linkages_sync_url
    assert_response :success
  end
end
