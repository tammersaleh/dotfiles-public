" Yaml Frontmatter in Haml (which our website uses)
let s:previous_syntax = b:current_syntax
unlet b:current_syntax
syntax include @YAML syntax/yaml.vim
syntax region hamlYamlFrontmatter matchgroup=Statement start=/\%^---$/ end=/^---$/ contains=@YAML
let b:current_syntax = s:previous_syntax
