require 'test_helper'

class VerificationTestController < ActionController::Base
  before_action :unconditional_redirect, only: :two_redirects

  verify only: :guarded_one, params: "one",
         add_flash: { error: 'unguarded' },
         redirect_to: { action: "unguarded" }

  verify only: :guarded_two, params: %w( one two ),
         redirect_to: { action: "unguarded" }

  verify only: :guarded_with_flash, :params => "one",
         add_flash: { :notice => "prereqs failed" },
         redirect_to: { action: "unguarded" }

  verify only: :guarded_in_session, session: "one",
         redirect_to: { action: "unguarded" }

  verify only: [:multi_one, :multi_two], session: %w( one two ),
         redirect_to: { action: "unguarded" }

  verify only: :guarded_by_method, method: :post,
         redirect_to: { action: "unguarded" }

  verify only: :guarded_by_xhr, xhr: true,
         redirect_to: { action: "unguarded" }

  verify only: :guarded_by_not_xhr, xhr: false,
         redirect_to: { action: "unguarded" }

  verify only: :two_redirects, method: :post,
         redirect_to: { action: :unguarded }

  verify only: :must_be_post, method: :post, render: { status: 405, plain: "Must be post" }, add_headers: { "Allow" => "POST" }

  verify only: :must_be_put, method: :put, render: { status: 405, plain: "Must be put" }, add_headers: { "Allow" => "PUT" }

  verify only: :guarded_one_for_named_route_test, params: "one", redirect_to: :foo_url

  verify only: :no_default_action, params: "santa"

  verify only: :guarded_with_back, method: :post, redirect_to: :back

  def guarded_one
    render plain: "#{params[:one]}"
  end

  def guarded_one_for_named_route_test
    render plain: "#{params[:one]}"
  end

  def guarded_with_flash
    render plain: "#{params[:one]}"
  end

  def guarded_two
    render plain: "#{params[:one]}:#{params[:two]}"
  end

  def guarded_in_session
    render plain: "#{session["one"]}"
  end

  def multi_one
    render plain: "#{session["one"]}:#{session["two"]}"
  end

  def multi_two
    render plain: "#{session["two"]}:#{session["one"]}"
  end

  def guarded_by_method
    render plain: "#{request.method}"
  end

  def guarded_by_xhr
    render plain: "#{!!request.xhr?}"
  end

  def guarded_by_not_xhr
    render plain: "#{!!request.xhr?}"
  end

  def unguarded
    render plain: "#{params[:one]}"
  end

  def two_redirects
    head :ok
  end

  def must_be_post
    render plain: "Was a post!"
  end

  def must_be_put
    render plain: "Was a put!"
  end

  def guarded_with_back
    render plain: "#{params[:one]}"
  end


  def no_default_action
    # Will never run
  end

  protected

  def unconditional_redirect
    redirect_to(action: "unguarded")
  end
end

class VerificationTest < ActionController::TestCase
  tests ::VerificationTestController

  def test_using_symbol_back_with_no_referrer
    assert_raise(ActionController::ActionControllerError) { get :guarded_with_back }
  end

  def test_using_symbol_back_redirects_to_referrer
    @request.env["HTTP_REFERER"] = "/foo"
    get :guarded_with_back

    assert_redirected_to('/foo')
  end

  def test_guarded_one_with_prereqs
    get :guarded_one, params: { one: "here" }

    assert_equal("here", @response.body)
  end

  def test_guarded_one_without_prereqs
    get :guarded_one

    assert_redirected_to(action: "unguarded")
    assert_equal('unguarded', flash[:error])
  end

  def test_guarded_with_flash_with_prereqs
    get :guarded_with_flash, params: { one: "here" }

    assert_equal("here", @response.body)
    assert(flash.empty?)
  end

  def test_guarded_with_flash_without_prereqs
    get :guarded_with_flash

    assert_redirected_to(action: "unguarded")
    assert_equal("prereqs failed", flash[:notice])
  end

  def test_guarded_two_with_prereqs
    get :guarded_two, params: { "one" => "here", "two" => "there" }

    assert_equal("here:there", @response.body)
  end

  def test_guarded_two_without_prereqs_one
    get :guarded_two, params: { two: "there" }

    assert_redirected_to(action: "unguarded")
  end

  def test_guarded_two_without_prereqs_two
    get :guarded_two, params: { one: "here" }

    assert_redirected_to(action: "unguarded")
  end

  def test_guarded_two_without_prereqs_both
    get :guarded_two

    assert_redirected_to(action: "unguarded")
  end

  def test_unguarded_with_params
    get :unguarded, params: {one: "here"}

    assert_equal("here", @response.body)
  end

  def test_unguarded_without_params
    get :unguarded

    assert(@response.body.blank?)
  end

  def test_guarded_in_session_with_prereqs
    get :guarded_in_session, session: { "one" => "here" }

    assert_equal("here", @response.body)
  end

  def test_guarded_in_session_without_prereqs
    get :guarded_in_session

    assert_redirected_to(action: "unguarded")
  end

  def test_multi_one_with_prereqs
    get :multi_one, session: { "one" => "here", "two" => "there" }

    assert_equal("here:there", @response.body)
  end

  def test_multi_one_without_prereqs
    get :multi_one

    assert_redirected_to(action: "unguarded")
  end

  def test_multi_two_with_prereqs
    get :multi_two, session: {"one" => "here", "two" => "there"}

    assert_equal("there:here", @response.body)
  end

  def test_multi_two_without_prereqs
    get :multi_two

    assert_redirected_to(action: "unguarded")
  end

  def test_guarded_by_method_with_prereqs
    post :guarded_by_method

    assert_equal("POST", @response.body)
  end

  def test_guarded_by_method_without_prereqs
    get :guarded_by_method

    assert_redirected_to(action: "unguarded")
  end

  def test_guarded_by_xhr_with_prereqs
    post :guarded_by_xhr, xhr: true

    assert_equal("true", @response.body)
  end

  def test_guarded_by_xhr_without_prereqs
    get :guarded_by_xhr

    assert_redirected_to(action: "unguarded")
  end

  def test_guarded_by_not_xhr_with_prereqs
    get :guarded_by_not_xhr

    assert_equal("false", @response.body)
  end

  def test_guarded_by_not_xhr_without_prereqs
    post :guarded_by_not_xhr, xhr: true

    assert_redirected_to(action: "unguarded")
  end

  def test_guarded_post_and_calls_render_succeeds
    post :must_be_post

    assert_equal("Was a post!", @response.body)
  end

  def test_guarded_put_and_calls_render_succeeds
    put :must_be_put

    assert_equal("Was a put!", @response.body)
  end

  def test_default_failure_should_be_a_bad_request
    post :no_default_action

    assert_response(:bad_request)
  end

  def test_guarded_post_and_calls_render_fails_and_sets_allow_header
    get :must_be_post

    assert_response(405)
    assert_equal("Must be post", @response.body)
    assert_equal("POST", @response.headers["Allow"])
  end

  def test_second_redirect
    assert_nothing_raised { get :two_redirects }
  end
end
