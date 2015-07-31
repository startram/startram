if ARGV.empty?
  puts "ERROR: Please provide view_dir as argument"
  exit
end

view_dir = ARGV.first

# When Dir.glob("**/*.ecr") works as in ruby we can get rid of this

def recursive_find(extension, path, found = [] of String)
  Dir.entries(path).each do |file_name|
    next if [".", ".."].includes?(file_name)

    full_path =  "#{path}/#{file_name}"
    if File.directory?(full_path)
      recursive_find(extension, full_path, found)
    elsif full_path.ends_with?(extension)
      found << full_path
    end
  end

  found
end

# Generates a view class for every .ecr template found under the given view_dir
# Directories under view_dir become part of the class name to avoid collision.
# Examples:
#  app/views/posts/index.ecr - PostsIndexView
#  app/views/posts/comments/new.ecr - PostsCommentsNewView

puts %(require "ecr/macros")

recursive_find(".ecr", view_dir).each do |file|
  underscored_name = file.gsub(view_dir, "").split("/").reject(&.empty?).join("_")
  class_name = File.basename(underscored_name, ".ecr").camelcase
  puts %(
    class #{class_name}View
      def initialize(@controller)
      end

      macro method_missing(name)
        @controller.@{{name.id}}.not_nil!
      end

      ecr_file "#{file}"
    end
  )
end
