require 'test_helper'

class CollectionItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get collection_items_index_url
    assert_response :success
  end

  test "should get edit" do
    get collection_items_edit_url
    assert_response :success
  end

end
