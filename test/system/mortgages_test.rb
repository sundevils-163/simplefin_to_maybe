require "application_system_test_case"

class MortgagesTest < ApplicationSystemTestCase
  setup do
    @mortgage = mortgages(:one)
  end

  test "visiting the index" do
    visit mortgages_url
    assert_selector "h1", text: "Mortgages"
  end

  test "should create mortgage" do
    visit mortgages_url
    click_on "New mortgage"

    fill_in "Identifier", with: @mortgage.identifier
    click_on "Create Mortgage"

    assert_text "Mortgage was successfully created"
    click_on "Back"
  end

  test "should update Mortgage" do
    visit mortgage_url(@mortgage)
    click_on "Edit this mortgage", match: :first

    fill_in "Identifier", with: @mortgage.identifier
    click_on "Update Mortgage"

    assert_text "Mortgage was successfully updated"
    click_on "Back"
  end

  test "should destroy Mortgage" do
    visit mortgage_url(@mortgage)
    accept_confirm { click_on "Destroy this mortgage", match: :first }

    assert_text "Mortgage was successfully destroyed"
  end
end
