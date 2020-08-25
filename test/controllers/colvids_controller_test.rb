require 'test_helper'

class ColvidsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get colvids_index_url
    assert_response :success
  end

  test "should get edit" do
    get colvids_edit_url
    assert_response :success
  end

end
