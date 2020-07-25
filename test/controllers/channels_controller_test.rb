require 'test_helper'

class ChannelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @channel = channels(:one)
  end

  test "should get index" do
    get channels_url
    assert_response :success
  end

  test "should get new" do
    get new_channel_url
    assert_response :success
  end

  test "should create channel" do
    assert_difference('Channel.count') do
      post channels_url, params: { channel: { activity: @channel.activity, activity_score: @channel.activity_score, channel_id: @channel.channel_id, country: @channel.country, custom_url: @channel.custom_url, description: @channel.description, has_related: @channel.has_related, id: @channel.id, origin: @channel.origin, retrieved_at: @channel.retrieved_at, rss_next_parsing: @channel.rss_next_parsing, show_related: @channel.show_related, thumbnail: @channel.thumbnail, title: @channel.title } }
    end

    assert_redirected_to channel_url(Channel.last)
  end

  test "should show channel" do
    get channel_url(@channel)
    assert_response :success
  end

  test "should get edit" do
    get edit_channel_url(@channel)
    assert_response :success
  end

  test "should update channel" do
    patch channel_url(@channel), params: { channel: { activity: @channel.activity, activity_score: @channel.activity_score, channel_id: @channel.channel_id, country: @channel.country, custom_url: @channel.custom_url, description: @channel.description, has_related: @channel.has_related, id: @channel.id, origin: @channel.origin, retrieved_at: @channel.retrieved_at, rss_next_parsing: @channel.rss_next_parsing, show_related: @channel.show_related, thumbnail: @channel.thumbnail, title: @channel.title } }
    assert_redirected_to channel_url(@channel)
  end

  test "should destroy channel" do
    assert_difference('Channel.count', -1) do
      delete channel_url(@channel)
    end

    assert_redirected_to channels_url
  end
end
