require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  setup :login_default_user

  test "show should 404 when when user without permissions requests page" do
    get :show, :id => accounts(:tim_checking).id
    assert_response :missing
  end

  test "create should 404 when when user without permissions requests page" do
    assert_no_difference "Account.count" do
      post :create, {
        :subscription_id => subscriptions(:tim).id,
        :account => { :name => "Savings", :role => "saving" } }
      assert_response :missing
    end
  end

  test "show should load account and subscription and render page" do
    get :show, :id => accounts(:john_checking).id
    assert_response :success
    assert_template "accounts/show"
    assert_equal accounts(:john_checking), assigns(:account)
    assert_equal subscriptions(:john), assigns(:subscription)
  end

  test "create should load subscription and create account and redirect" do
    assert_difference "subscriptions(:john).accounts.count" do
      post :create, {
        :subscription_id => subscriptions(:john).id,
        :account => { :name => "Mortgage", :role => "" } }
      assert_redirected_to(subscription_url(subscriptions(:john)))
    end

    assert_equal subscriptions(:john), assigns(:subscription)
    assert assigns(:account)
  end

  test "destroy should 404 when user without permission requests page" do
    assert_no_difference "Account.count" do
      delete :destroy, :id => accounts(:tim_checking).id
      assert_response :missing
    end
  end

  test "destroy should remove account and redirect" do
    assert_difference "Account.count", -1 do
      delete :destroy, :id => accounts(:john_mastercard).id
      assert_redirected_to(subscription_url(subscriptions(:john)))
    end
  end

  test "update should 404 when user without permissions requests page" do
    xhr :put, :update, :id => accounts(:tim_checking).id, :account => { :name => "Hi!" }
    assert_response :missing
    assert_equal "Checking", accounts(:tim_checking, :reload).name
  end

  test "update should change account name and render javascript" do
    xhr :put, :update, :id => accounts(:john_checking).id, :account => { :name => "Hi!" }
    assert_response :success
    assert_template "accounts/update.js.rjs"
    assert_equal subscriptions(:john), assigns(:subscription)
    assert_equal accounts(:john_checking), assigns(:account)
    assert_equal "Hi!", accounts(:john_checking, :reload).name
  end
end
