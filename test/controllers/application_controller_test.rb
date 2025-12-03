require "test_helper"

class ApplicationControllerTest < ActionController::TestCase
  tests ApplicationController

  def setup
    @user = users(:portfolio_user)
  end

  test "re_authenticate_current_user should do nothing for non admin paths" do
    called = false
    @controller.define_singleton_method(:current_user) { @user }
    @controller.define_singleton_method(:bypass_sign_in) do |_user|
      called = true
    end

    @controller.instance_variable_set(:@object, @user)
    @request.path = "/profile"
    @request.request_method = "PATCH"

    @controller.send(:re_authenticate_current_user)
    refute called, "bypass_sign_in should not be called when path is not under /admin"
  end
end


