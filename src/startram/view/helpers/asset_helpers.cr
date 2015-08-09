module Startram
  class View
    module Helpers
      ASSET_EXTENSIONS = {
        :javascript => ".js"
        :stylesheet => ".css"
      }

      ASSET_DIRECTORIES = {
        :audio => "/audios"
        :font => "/fonts"
        :image => "/images"
        :javascript => "/javascripts"
        :stylesheet => "/stylesheets"
        :video => "/videos"
        nil => ""
      }

      def asset_path(source : String, format = nil)
        path = ASSET_DIRECTORIES.fetch(format, "")
        ext = ASSET_EXTENSIONS.fetch(format, nil)

        ext = nil if ext && source.ends_with?(ext)

        "#{path}/#{source}#{ext}"
      end

      def javascript_include_tag(source : String | Array(String))
        source = [source] if source.is_a?(String)

        tags = source.inject(StringIO.new) do |string, source|
          string << %(<script src="#{asset_path(source, :javascript)}"></script>)
        end

        tags.to_s
      end

      def stylesheet_link_tag(source : String | Array(String), media = :all)
        source = [source] if source.is_a?(String)

        tags = source.inject(StringIO.new) do |string, source|
          string << %(<link rel="stylesheet" media="#{media}" href="/stylesheets/#{source}.css">)
        end

        tags.to_s
      end
    end
  end
end
