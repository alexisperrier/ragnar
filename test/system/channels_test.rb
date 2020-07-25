require "application_system_test_case"

class ChannelsTest < ApplicationSystemTestCase
  setup do
    @channel = channels(:one)
  end

  test "visiting the index" do
    visit channels_url
    assert_selector "h1", text: "Channels"
  end

  test "creating a Channel" do
    visit channels_url
    click_on "New Channel"

    fill_in "Activity", with: @channel.activity
    fill_in "Activity score", with: @channel.activity_score
    fill_in "Channel", with: @channel.channel_id
    fill_in "Country", with: @channel.country
    fill_in "Custom url", with: @channel.custom_url
    fill_in "Description", with: @channel.description
    check "Has related" if @channel.has_related
    fill_in "Id", with: @channel.id
    fill_in "Origin", with: @channel.origin
    fill_in "Retrieved at", with: @channel.retrieved_at
    fill_in "Rss next parsing", with: @channel.rss_next_parsing
    fill_in "Show related", with: @channel.show_related
    fill_in "Thumbnail", with: @channel.thumbnail
    fill_in "Title", with: @channel.title
    click_on "Create Channel"

    assert_text "Channel was successfully created"
    click_on "Back"
  end

  test "updating a Channel" do
    visit channels_url
    click_on "Edit", match: :first

    fill_in "Activity", with: @channel.activity
    fill_in "Activity score", with: @channel.activity_score
    fill_in "Channel", with: @channel.channel_id
    fill_in "Country", with: @channel.country
    fill_in "Custom url", with: @channel.custom_url
    fill_in "Description", with: @channel.description
    check "Has related" if @channel.has_related
    fill_in "Id", with: @channel.id
    fill_in "Origin", with: @channel.origin
    fill_in "Retrieved at", with: @channel.retrieved_at
    fill_in "Rss next parsing", with: @channel.rss_next_parsing
    fill_in "Show related", with: @channel.show_related
    fill_in "Thumbnail", with: @channel.thumbnail
    fill_in "Title", with: @channel.title
    click_on "Update Channel"

    assert_text "Channel was successfully updated"
    click_on "Back"
  end

  test "destroying a Channel" do
    visit channels_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Channel was successfully destroyed"
  end
end
