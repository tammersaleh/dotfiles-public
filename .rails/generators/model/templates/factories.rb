
Factory.define :<%= file_name %> do |f|
<% attributes.each do |attribute| -%>
  f.<%= attribute.name %> "<%= attribute.column.human_name %>"
<% end -%>
end

