class <%= class_name %> < ActiveRecord::Base
  attr_accessible <%= attributes.map {|a| ":#{a.name}" }.join(', ') %>
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
end
