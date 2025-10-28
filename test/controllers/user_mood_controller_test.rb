require "test_helper"

class UserMoodControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get user_mood_home_url
    assert_response :success
  end
end
