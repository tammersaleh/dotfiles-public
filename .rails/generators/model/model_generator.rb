module Tammer #:nodoc:
  module Generator #:nodoc:
    module Commands #:nodoc:
      module Create
        def append_to_file(relative_source, relative_destination, file_options = {}, &block)
          # Determine full paths for source and destination files.
          source      = source_path(relative_source)
          destination = destination_path(relative_destination)

          logger.append relative_destination

          # If we're pretending, back off now.
          return if options[:pretend]

          # Write destination file with optional shebang.  Yield for content
          # if block given so templaters may render the source file.  If a
          # shebang is requested, replace the existing shebang or insert a
          # new one.
          File.open(destination, 'a+b') do |dest|
            dest.write render_file(source, file_options, &block)
          end

          # Optionally add file to subversion or git
          system("svn add #{destination}") if options[:svn]
          system("git add -v #{relative_destination}") if options[:git]
        end

        def append_template(relative_source, relative_destination, template_options = {})
          append_to_file(relative_source, relative_destination, template_options) do |file|
            # Evaluate any assignments in a temporary, throwaway binding.
            vars = template_options[:assigns] || {}
            b = template_options[:binding] || binding
            vars.each { |k,v| eval "#{k} = vars[:#{k}] || vars['#{k}']", b }

            # Render the source file with the temporary binding.
            ERB.new(file.read, nil, '-').result(b)
          end
        end
      end
    end
  end
end

Rails::Generator::Commands::Create.send :include, Tammer::Generator::Commands::Create

class ModelGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_migration => false

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_name, "#{class_name}Test"

      # Model, test, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)

      # Model class, unit test, and fixtures.
      m.template        'model.rb',     File.join('app/models', class_path, "#{file_name}.rb")
      m.template        'unit_test.rb', File.join('test/unit', class_path, "#{file_name}_test.rb")
      m.append_template 'factories.rb', File.join('test/factories.rb')

      migration_file_path = file_path.gsub(/\//, '_')
      migration_name = class_name
      if ActiveRecord::Base.pluralize_table_names
        migration_name = migration_name.pluralize
        migration_file_path = migration_file_path.pluralize
      end

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{migration_name.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{migration_file_path}"
      end
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    end
end
