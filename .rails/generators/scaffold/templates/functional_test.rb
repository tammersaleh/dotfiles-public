require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  as_a_logged_in_user do
    context "on GET to /<%= table_name %>/new" do
      setup { get :new }

      should_render_template :new
      should_respond_with :success
      should_not_set_the_flash
    end

    context "on POST to /<%= table_name %> with good values" do
      setup do
        post :create, 
             :<%= file_name %> => {
<% attributes.each do |attr| -%>
               :<%= attr.name %> => "<%= attr.column.human_name %>",
<% end -%>
             }
      end

      should_redirect_to("<%= file_name %> page") { <%= file_name %>_path(assigns(:<%= file_name %>)) }
      should_set_the_flash_to /created/i
      should_create(:<%= file_name %>)
    end

    context "given a <%= file_name %>" do
      setup { @<%= file_name %> = Factory(:<%= file_name %>) }

      context "on GET to /<%= table_name %>/" do
        setup { get :index }

        should_render_template :index
        should_respond_with :success
        should_not_set_the_flash
      end

      context "on GET to /<%= table_name %>/:id" do
        setup { get :show, :id => @<%= file_name %>.to_param }

        should_render_template :show
        should_respond_with :success
        should_not_set_the_flash
      end

      context "on GET to /<%= table_name %>/:id/edit" do
        setup { get :edit, :id => @<%= file_name %>.to_param }

        should_render_template :edit
        should_respond_with :success
        should_not_set_the_flash
      end

      context "on PUT to /<%= table_name %>/:id with good values" do
        setup do
          put :update, 
              :id => @<%= file_name %>.to_param, 
              :<%= file_name %> => {
<% attributes.each do |attr| -%>
                :<%= attr.name %> => "<%= attr.column.human_name %>",
<% end -%>
              }
        end

        should_redirect_to("<%= table_name %> page") { <%= file_name %>_path(@<%= file_name %>) }
        should_set_the_flash_to /updated/i
      end

      context "on DELETE to /<%= table_name %>/:id" do
        setup { delete :destroy, :id => @<%= file_name %>.to_param }
        should_redirect_to("<%= table_name %> index") { <%= table_name %>_path }
        should_destroy(:<%= file_name %>)
      end
    end
  end
end
