require 'test_helper'

class VerificationTestController < ActionController::Base
  verify :only => :guarded_one, params: "one",
  # verify only: :guarded_one, params: { "one" },
         :add_flash => { :error => 'unguarded' },
        #  flash: { error: 'unguarded' },
         :redirect_to => { :action => "unguarded" }
        #  redirect_to({ action: :unguarded })

  # verify only: :guarded_two, params: { %w( one two ) },
  verify only: :guarded_two, params: "%w( one two )",
         :redirect_to => { :action => "unguarded" }
        #  redirect_to({ action: :unguarded })

  verify only: :guarded_with_flash, :params => "one",
  # verify only: :guarded_with_flash, params: { "one": "ONE" },
        #  flash: { notice: "prereqs failed" },
         :add_flash => { :notice => "prereqs failed" },
         :redirect_to => { :action => "unguarded" }
        #  redirect_to({ action: :unguarded })

  verify only: :guarded_in_session, :session => "one",
  # verify only: :guarded_in_session, session: { "one" },
         :redirect_to => { :action => "unguarded" }
        #  redirect_to({ action: :unguarded })

  verify only: [:multi_one, :multi_two], :session => %w( one two ),
  # verify only: [:multi_one, :multi_two], session: { %w( one two ) },
         :redirect_to => { :action => "unguarded" }
        #  redirect_to({ action: :unguarded })

  verify only: :guarded_by_method, method: :post,
         :redirect_to => { :action => "unguarded" }
        #  redirect_to({ action: :unguarded })

  verify only: :guarded_by_xhr, :xhr => true,
  # verify only: :guarded_by_xhr, xhr: true,
         :redirect_to => { :action => "unguarded" }
        #  redirect_to({ action: :unguarded })

  verify only: :guarded_by_not_xhr, :xhr => false,
  # verify only: :guarded_by_not_xhr, xhr: false,
         :redirect_to => { :action => "unguarded" }
        #  redirect_to({ action: :unguarded })

  if respond_to?(:before_action)
    before_action :unconditional_redirect, only: :two_redirects
  else
    before_filter :unconditional_redirect, only: :two_redirects
  end

  verify only: :two_redirects, method: :post,
         :redirect_to => { :action => "unguarded" }
        #  redirect_to:({ :action => "unguarded" })
  # begin
    verify only: :must_be_post, method: :post, :render => { :status => 405, plain: "Must be post" }, :add_headers => { "Allow" => "POST" }
  # rescue ActionView::MissingTemplate
    # verify only: :must_be_post, method: :post, :render => { :status => 405, :text => "Must be post" }, :add_headers => { "Allow" => "POST" }
    # verify only: :must_be_post, method: :post, render: { :status => 405, :text => "Must be post" }, add_headers: { "Allow" => "POST" }
  # end

  # begin
    verify only: :must_be_put, method: :put, :render => { :status => 405, plain: "Must be put" }, :add_headers => { "Allow" => "PUT" }
  # rescue ActionView::MissingTemplate
    # verify only: :must_be_put, method: :put, :render => { :status => 405, :text => "Must be put" }, :add_headers => { "Allow" => "PUT" }
    # verify only: :must_be_put, method: :put, render: { :status => 405, :text => "Must be put" }, add_headers: { "Allow" => "PUT" }
  # end

  verify only: :guarded_one_for_named_route_test, :params => "one",
         :redirect_to => :foo_url
        #  redirect_to:(:foo_url)

  verify only: :no_default_action, :params => "santa"

  # verify only: :guarded_with_back, method: :post, redirect_to: :back
  verify only: :guarded_with_back, method: :post, :redirect_to => :back, fallback_location: '/'
        #  :redirect_to => :back
        # begin
        #   :redirect_to => :back
        # rescue NoMethodError
          # redirect_back
        # end
        #  redirect_to:(:back)

  def guarded_one
    begin
      render plain: "#{params[:one]}"
    rescue ActionView::MissingTemplate
      render text: "#{params[:one]}"
    end
  end

  def guarded_one_for_named_route_test
    begin
      render plain: "#{params[:one]}"
    rescue ActionView::MissingTemplate
      render text: "#{params[:one]}"
    end
  end

  def guarded_with_flash
    begin
      render plain: "#{params[:one]}"
    rescue ActionView::MissingTemplate
      render text: "#{params[:one]}"
    end
  end

  def guarded_two
    begin
      render plain: "#{params[:one]}:#{params[:two]}"
    rescue ActionView::MissingTemplate
      render text: "#{params[:one]}:#{params[:two]}"
    end
  end

  def guarded_in_session
    begin
      render plain: "#{session["one"]}"
    rescue ActionView::MissingTemplate
      render text: "#{session["one"]}"
    end
  end

  def multi_one
    begin
      render plain: "#{session["one"]}:#{session["two"]}"
    rescue ActionView::MissingTemplate
      render text: "#{session["one"]}:#{session["two"]}"
    end
  end

  def multi_two
    begin
      render plain: "#{session["two"]}:#{session["one"]}"
    rescue ActionView::MissingTemplate
      render text: "#{session["two"]}:#{session["one"]}"
    end
  end

  def guarded_by_method
    begin
      render plain: "#{request.method}"
    rescue ActionView::MissingTemplate
      render text: "#{request.method}"
    end
  end

  def guarded_by_xhr
    begin
      render plain: "#{!!request.xhr?}"
    rescue ActionView::MissingTemplate
      render text: "#{!!request.xhr?}"
    end
  end

  def guarded_by_not_xhr
    begin
      render plain: "#{!!request.xhr?}"
    rescue ActionView::MissingTemplate
      render text: "#{!!request.xhr?}"
    end
  end

  def unguarded
    begin
      render plain: "#{params[:one]}"
    rescue ActionView::MissingTemplate
      render text: "#{params[:one]}"
    end
  end

  def two_redirects
    head :ok
    # render :nothing => true
  end

  def must_be_post
    begin
      render plain: "Was a post!"
    rescue ActionView::MissingTemplate
      render text: "Was a post!"
    end
  end

  def must_be_put
    begin
      render plain: "Was a put!"
    rescue ActionView::MissingTemplate
      render text: "Was a put!"
    end
  end

  def guarded_with_back
    begin
      render plain: "#{params[:one]}"
    rescue ActionView::MissingTemplate
      render text: "#{params[:one]}"
    end
  end


  def no_default_action
    # Will never run
  end

  protected

  def unconditional_redirect
    redirect_to :action => "unguarded"
    # redirect_to({action: :unguarded})
  end
end

class VerificationTest < ActionController::TestCase
  tests ::VerificationTestController

  def test_using_symbol_back_with_no_referrer
    assert_raise { get :guarded_with_back }
  end

  def test_using_symbol_back_redirects_to_referrer
    @request.env["HTTP_REFERER"] = "/foo"
    get :guarded_with_back
    assert_redirected_to '/foo'
  end

  def test_guarded_one_with_prereqs
    # get :guarded_one, :one => "here"
    get :guarded_one, params: {:one => "here"}
    assert_equal "here", @response.body
  end

  def test_guarded_one_without_prereqs
    get :guarded_one
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
    assert_equal 'unguarded', flash[:error]
  end

  def test_guarded_with_flash_with_prereqs
    # get :guarded_with_flash, :one => "here"
    get :guarded_with_flash, params: {:one => "here"}
    assert_equal "here", @response.body
    assert flash.empty?
  end

  def test_guarded_with_flash_without_prereqs
    get :guarded_with_flash
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
    assert_equal "prereqs failed", flash[:notice]
  end

  def test_guarded_two_with_prereqs
    # get :guarded_two, :one => "here", :two => "there"
    get :guarded_two, params: {:one => "here", :two => "there"}
    assert_equal "here:there", @response.body
  end

  def test_guarded_two_without_prereqs_one
    # get :guarded_two, :two => "there"
    get :guarded_two, params: {:two => "there"}
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
  end

  def test_guarded_two_without_prereqs_two
    # get :guarded_two, :one => "here"
    get :guarded_two, params: {:one => "here"}
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
  end

  def test_guarded_two_without_prereqs_both
    get :guarded_two
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
  end

  def test_unguarded_with_params
    # get :unguarded, :one => "here"
    get :unguarded, params: {:one => "here"}
    assert_equal "here", @response.body
  end

  def test_unguarded_without_params
    get :unguarded
    assert @response.body.blank?
  end

  def test_guarded_in_session_with_prereqs
    # get :guarded_in_session, {}, "one" => "here"
    get :guarded_in_session, params: {"one" => "here"}
    assert_equal "here", @response.body
  end

  def test_guarded_in_session_without_prereqs
    get :guarded_in_session
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
  end

  def test_multi_one_with_prereqs
    # get :multi_one, {}, "one" => "here", "two" => "there"
    get :multi_one, params: {"one" => "here", "two" => "there"}
    assert_equal "here:there", @response.body
  end

  def test_multi_one_without_prereqs
    get :multi_one
    assert_redirected_to :action => "unguarded"
  end

  def test_multi_two_with_prereqs
    get :multi_two, params: {"one" => "here", "two" => "there"}
    assert_equal "there:here", @response.body
  end

  def test_multi_two_without_prereqs
    get :multi_two
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
  end

  def test_guarded_by_method_with_prereqs
    post :guarded_by_method
    assert_equal "POST", @response.body
  end

  def test_guarded_by_method_without_prereqs
    get :guarded_by_method
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
  end

  def test_guarded_by_xhr_with_prereqs
    if respond_to?(:xhr)
      xhr :post, :guarded_by_xhr
      assert_equal "true", @response.body
    else
      return
    end
  end

  def test_guarded_by_xhr_without_prereqs
    get :guarded_by_xhr
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
  end

  def test_guarded_by_not_xhr_with_prereqs
    get :guarded_by_not_xhr
    assert_equal "false", @response.body
  end

  def test_guarded_by_not_xhr_without_prereqs
    xhr :post, :guarded_by_not_xhr
    assert_redirected_to :action => "unguarded"
    # assert_redirected_to(action: :unguarded)
  end

  def test_guarded_post_and_calls_render_succeeds
    post :must_be_post
    assert_equal "Was a post!", @response.body
  end

  def test_guarded_put_and_calls_render_succeeds
    put :must_be_put
    assert_equal "Was a put!", @response.body
  end

  def test_default_failure_should_be_a_bad_request
    post :no_default_action
    assert_response :bad_request
  end

  def test_guarded_post_and_calls_render_fails_and_sets_allow_header
    get :must_be_post
    assert_response 405
    assert_equal "Must be post", @response.body
    assert_equal "POST", @response.headers["Allow"]
  end

  def test_second_redirect
    assert_nothing_raised { get :two_redirects }
  end
end
