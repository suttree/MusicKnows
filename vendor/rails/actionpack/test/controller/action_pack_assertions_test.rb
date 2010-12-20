require File.dirname(__FILE__) + '/../abstract_unit'

# a controller class to facilitate the tests
class ActionPackAssertionsController < ActionController::Base

  # this does absolutely nothing
  def nothing() render_text ""; end

  # a standard template
  def hello_world() render "test/hello_world"; end

  # a standard template
  def hello_xml_world() render "test/hello_xml_world"; end

  # a redirect to an internal location
  def redirect_internal() redirect_to "/nothing"; end

  def redirect_to_action() redirect_to :action => "flash_me", :id => 1, :params => { "panda" => "fun" }; end

  def redirect_to_controller() redirect_to :controller => "elsewhere", :action => "flash_me"; end

  def redirect_to_path() redirect_to '/some/path' end

  def redirect_to_named_route() redirect_to route_one_url end

  # a redirect to an external location
  def redirect_external() redirect_to_url "http://www.rubyonrails.org"; end

  # a 404
  def response404() render_text "", "404 AWOL"; end

  # a 500
  def response500() render_text "", "500 Sorry"; end

  # a fictional 599
  def response599() render_text "", "599 Whoah!"; end

  # putting stuff in the flash
  def flash_me
    flash['hello'] = 'my name is inigo montoya...'
    render_text "Inconceivable!"
  end

  # we have a flash, but nothing is in it
  def flash_me_naked
    flash.clear
    render_text "wow!"
  end

  # assign some template instance variables
  def assign_this
    @howdy = "ho"
    render :inline => "Mr. Henke"
  end

  def render_based_on_parameters
    render_text "Mr. #{params[:name]}"
  end

  def render_url
    render_text "<div>#{url_for(:action => 'flash_me', :only_path => true)}</div>"
  end

  def render_text_with_custom_content_type
    render :text => "Hello!", :content_type => Mime::RSS
  end

  # puts something in the session
  def session_stuffing
    session['xmas'] = 'turkey'
    render_text "ho ho ho"
  end

  # raises exception on get requests
  def raise_on_get
    raise "get" if request.get?
    render_text "request method: #{request.env['REQUEST_METHOD']}"
  end

  # raises exception on post requests
  def raise_on_post
    raise "post" if request.post?
    render_text "request method: #{request.env['REQUEST_METHOD']}"
  end

  def get_valid_record
    @record = Class.new do
      def valid?
        true
      end

      def errors
        Class.new do
           def full_messages; []; end
        end.new
      end

    end.new

    render :nothing => true
  end


  def get_invalid_record
    @record = Class.new do

      def valid?
        false
      end

      def errors
        Class.new do
           def full_messages; ['...stuff...']; end
        end.new
      end
    end.new

    render :nothing => true
  end

  # 911
  def rescue_action(e) raise; end
end

module Admin
  class InnerModuleController < ActionController::Base
    def index
      render :nothing => true
    end

    def redirect_to_index
      redirect_to admin_inner_module_path
    end

    def redirect_to_absolute_controller
      redirect_to :controller => '/content'
    end

    def redirect_to_fellow_controller
      redirect_to :controller => 'user'
    end
  end
end

# ---------------------------------------------------------------------------


# tell the controller where to find its templates but start from parent
# directory of test_request_response to simulate the behaviour of a
# production environment
ActionPackAssertionsController.template_root = File.dirname(__FILE__) + "/../fixtures/"


# a test case to exercise the new capabilities TestRequest & TestResponse
class ActionPackAssertionsControllerTest < Test::Unit::TestCase
  # let's get this party started
  def setup
    @controller = ActionPackAssertionsController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  # -- assertion-based testing ------------------------------------------------

  def test_assert_tag_and_url_for
    get :render_url
    assert_tag :content => "/action_pack_assertions/flash_me"
  end

  # test the session assertion to make sure something is there.
  def test_assert_session_has
    process :session_stuffing
    assert_deprecated_assertion { assert_session_has 'xmas' }
    assert_deprecated_assertion { assert_session_has_no 'halloween' }
  end

  # test the get method, make sure the request really was a get
  def test_get
    assert_raise(RuntimeError) { get :raise_on_get }
    get :raise_on_post
    assert_equal @response.body, 'request method: GET'
  end

  # test the get method, make sure the request really was a get
  def test_post
    assert_raise(RuntimeError) { post :raise_on_post }
    post :raise_on_get
    assert_equal @response.body, 'request method: POST'
  end

#   the following test fails because the request_method is now cached on the request instance
#   test the get/post switch within one test action
#   def test_get_post_switch
#     post :raise_on_get
#     assert_equal @response.body, 'request method: POST'
#     get :raise_on_post
#     assert_equal @response.body, 'request method: GET'
#     post :raise_on_get
#     assert_equal @response.body, 'request method: POST'
#     get :raise_on_post
#     assert_equal @response.body, 'request method: GET'
#   end

  # test the assertion of goodies in the template
  def test_assert_template_has
    process :assign_this
    assert_deprecated_assertion { assert_template_has 'howdy' }
  end

  # test the assertion for goodies that shouldn't exist in the template
  def test_assert_template_has_no
    process :nothing
    assert_deprecated_assertion { assert_template_has_no 'maple syrup' }
    assert_deprecated_assertion { assert_template_has_no 'howdy' }
  end

  # test the redirection assertions
  def test_assert_redirect
    process :redirect_internal
    assert_deprecated_assertion { assert_redirect }
  end

  # test the redirect url string
  def test_assert_redirect_url
    process :redirect_external
    assert_deprecated_assertion do
      assert_redirect_url 'http://www.rubyonrails.org'
    end
  end

  # test the redirection pattern matching on a string
  def test_assert_redirect_url_match_string
    process :redirect_external
    assert_deprecated_assertion do
      assert_redirect_url_match 'rails.org'
    end
  end

  # test the redirection pattern matching on a pattern
  def test_assert_redirect_url_match_pattern
    process :redirect_external
    assert_deprecated_assertion do
      assert_redirect_url_match /ruby/
    end
  end

  # test the redirection to a named route
  def test_assert_redirect_to_named_route
    with_routing do |set|
      set.draw do |map|
        map.route_one 'route_one', :controller => 'action_pack_assertions', :action => 'nothing'
        map.connect   ':controller/:action/:id'
      end
      set.named_routes.install

      process :redirect_to_named_route
      assert_redirected_to 'http://test.host/route_one'
      assert_redirected_to route_one_url
      assert_redirected_to :route_one_url
    end
  end

  def test_assert_redirect_to_named_route_failure
    with_routing do |set|
      set.draw do |map|
        map.route_one 'route_one', :controller => 'action_pack_assertions', :action => 'nothing', :id => 'one'
        map.route_two 'route_two', :controller => 'action_pack_assertions', :action => 'nothing', :id => 'two'
        map.connect   ':controller/:action/:id'
      end
      process :redirect_to_named_route
      assert_raise(Test::Unit::AssertionFailedError) do
        assert_redirected_to 'http://test.host/route_two'
      end
      assert_raise(Test::Unit::AssertionFailedError) do
        assert_redirected_to :controller => 'action_pack_assertions', :action => 'nothing', :id => 'two'
      end
      assert_raise(Test::Unit::AssertionFailedError) do
        assert_redirected_to route_two_url
      end
      assert_raise(Test::Unit::AssertionFailedError) do
        assert_redirected_to :route_two_url
      end
    end
  end

  def test_assert_redirect_to_nested_named_route
    with_routing do |set|
      set.draw do |map|
        map.admin_inner_module 'admin/inner_module', :controller => 'admin/inner_module', :action => 'index'
        map.connect            ':controller/:action/:id'
      end
      @controller = Admin::InnerModuleController.new
      process :redirect_to_index
      # redirection is <{"action"=>"index", "controller"=>"admin/admin/inner_module"}>
      assert_redirected_to admin_inner_module_path
    end
  end

  # test the flash-based assertions with something is in the flash
  def test_flash_assertions_full
    process :flash_me
    assert @response.has_flash_with_contents?
    assert_deprecated_assertion { assert_flash_exists }
    assert_deprecated_assertion { assert_flash_not_empty }
    assert_deprecated_assertion { assert_flash_has 'hello' }
    assert_deprecated_assertion { assert_flash_has_no 'stds' }
  end

  # test the flash-based assertions with no flash at all
  def test_flash_assertions_negative
    process :nothing
    assert_deprecated_assertion { assert_flash_empty }
    assert_deprecated_assertion { assert_flash_has_no 'hello' }
    assert_deprecated_assertion { assert_flash_has_no 'qwerty' }
  end

  # test the assert_rendered_file
  def test_assert_rendered_file
    assert_deprecated(/render/) { process :hello_world }
    assert_deprecated_assertion { assert_rendered_file 'test/hello_world' }
    assert_deprecated_assertion { assert_rendered_file 'hello_world' }
  end

  # test the assert_success assertion
  def test_assert_success
    process :nothing
    assert_deprecated_assertion { assert_success }
  end

  # -- standard request/response object testing --------------------------------

  # ensure our session is working properly
  def test_session_objects
    process :session_stuffing
    assert @response.has_session_object?('xmas')
    assert_deprecated_assertion { assert_session_equal 'turkey', 'xmas' }
    assert !@response.has_session_object?('easter')
  end

  # make sure that the template objects exist
  def test_template_objects_alive
    process :assign_this
    assert !@response.has_template_object?('hi')
    assert @response.has_template_object?('howdy')
  end

  # make sure we don't have template objects when we shouldn't
  def test_template_object_missing
    process :nothing
    assert_nil @response.template_objects['howdy']
  end

  def test_assigned_equal
    process :assign_this
    assert_deprecated_assertion { assert_assigned_equal "ho", :howdy }
  end

  # check the empty flashing
  def test_flash_me_naked
    process :flash_me_naked
    assert !@response.has_flash?
    assert !@response.has_flash_with_contents?
  end

  # check if we have flash objects
  def test_flash_haves
    process :flash_me
    assert @response.has_flash?
    assert @response.has_flash_with_contents?
    assert @response.has_flash_object?('hello')
  end

  # ensure we don't have flash objects
  def test_flash_have_nots
    process :nothing
    assert !@response.has_flash?
    assert !@response.has_flash_with_contents?
    assert_nil @response.flash['hello']
  end

  # examine that the flash objects are what we expect
  def test_flash_equals
    process :flash_me
    assert_deprecated_assertion do
      assert_flash_equal 'my name is inigo montoya...', 'hello'
    end
  end

  # check if we were rendered by a file-based template?
  def test_rendered_action
    process :nothing
    assert !@response.rendered_with_file?

    assert_deprecated(/render/) { process :hello_world }
    assert @response.rendered_with_file?
    assert 'hello_world', @response.rendered_file
  end

  # check the redirection location
  def test_redirection_location
    process :redirect_internal
    assert_equal 'http://test.host/nothing', @response.redirect_url

    process :redirect_external
    assert_equal 'http://www.rubyonrails.org', @response.redirect_url

    process :nothing
    assert_nil @response.redirect_url
  end


  # check server errors
  def test_server_error_response_code
    process :response500
    assert @response.server_error?

    process :response599
    assert @response.server_error?

    process :response404
    assert !@response.server_error?
  end

  # check a 404 response code
  def test_missing_response_code
    process :response404
    assert @response.missing?
  end

  # check to see if our redirection matches a pattern
  def test_redirect_url_match
    process :redirect_external
    assert @response.redirect?
    assert @response.redirect_url_match?("rubyonrails")
    assert @response.redirect_url_match?(/rubyonrails/)
    assert !@response.redirect_url_match?("phpoffrails")
    assert !@response.redirect_url_match?(/perloffrails/)
  end

  # check for a redirection
  def test_redirection
    process :redirect_internal
    assert @response.redirect?

    process :redirect_external
    assert @response.redirect?

    process :nothing
    assert !@response.redirect?
  end

  # check a successful response code
  def test_successful_response_code
    process :nothing
    assert @response.success?
  end

  # a basic check to make sure we have a TestResponse object
  def test_has_response
    process :nothing
    assert_kind_of ActionController::TestResponse, @response
  end

  def test_render_based_on_parameters
    process :render_based_on_parameters, "name" => "David"
    assert_equal "Mr. David", @response.body
  end

  def test_assert_template_xpath_match_no_matches
    assert_deprecated(/render/) { process :hello_xml_world }
    assert_raises Test::Unit::AssertionFailedError do
      assert_deprecated_assertion do
        assert_template_xpath_match('/no/such/node/in/document')
      end
    end
  end

  def test_simple_one_element_xpath_match
    assert_deprecated(/render/) { process :hello_xml_world }
    assert_deprecated_assertion do
      assert_template_xpath_match('//title', "Hello World")
    end
  end

  def test_array_of_elements_in_xpath_match
    assert_deprecated(/render/) { process :hello_xml_world }
    assert_deprecated_assertion do
      assert_template_xpath_match('//p', %w( abes monks wiseguys ))
    end
  end

  def test_follow_redirect
    process :redirect_to_action
    assert_redirected_to :action => "flash_me"

    follow_redirect
    assert_equal 1, @request.parameters["id"].to_i

    assert "Inconceivable!", @response.body
  end

  def test_follow_redirect_outside_current_action
    process :redirect_to_controller
    assert_redirected_to :controller => "elsewhere", :action => "flash_me"

    assert_raises(RuntimeError, "Can't follow redirects outside of current controller (elsewhere)") { follow_redirect }
  end

  def test_assert_redirection_fails_with_incorrect_controller
    process :redirect_to_controller
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_redirected_to :controller => "action_pack_assertions", :action => "flash_me"
    end
  end

  def test_assert_redirection_with_extra_controller_option
    get :redirect_to_action
    assert_redirected_to :controller => 'action_pack_assertions', :action => "flash_me", :id => 1, :params => { :panda => 'fun' }
  end

  def test_redirected_to_url_leadling_slash
    process :redirect_to_path
    assert_redirected_to '/some/path'
  end
  def test_redirected_to_url_no_leadling_slash
    process :redirect_to_path
    assert_redirected_to 'some/path'
  end
  def test_redirected_to_url_full_url
    process :redirect_to_path
    assert_redirected_to 'http://test.host/some/path'
  end

  def test_redirected_to_with_nested_controller
    @controller = Admin::InnerModuleController.new
    get :redirect_to_absolute_controller
    assert_redirected_to :controller => 'content'

    get :redirect_to_fellow_controller
    assert_redirected_to :controller => 'admin/user'
  end

  def test_assert_valid
    get :get_valid_record
    assert_valid assigns('record')
  end

  def test_assert_valid_failing
    get :get_invalid_record

    begin
      assert_valid assigns('record')
      assert false
    rescue Test::Unit::AssertionFailedError => e
    end
  end

  protected
    def assert_deprecated_assertion(&block)
      assert_deprecated(/assert/, &block)
    end
end

class ActionPackHeaderTest < Test::Unit::TestCase
  def setup
    @controller = ActionPackAssertionsController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  def test_rendering_xml_sets_content_type
    assert_deprecated(/render/) { process :hello_xml_world }
    assert_equal('application/xml; charset=utf-8', @controller.headers['Content-Type'])
  end

  def test_rendering_xml_respects_content_type
    @response.headers['Content-Type'] = 'application/pdf'
    assert_deprecated(/render/) { process :hello_xml_world }
    assert_equal('application/pdf; charset=utf-8', @controller.headers['Content-Type'])
  end


  def test_render_text_with_custom_content_type
    get :render_text_with_custom_content_type
    assert_equal 'application/rss+xml; charset=utf-8', @response.headers['Content-Type']
  end
end
