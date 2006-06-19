require "rss/0.9"

module RSS

  class Rss

    class Channel

      [
        ["generator"],
        ["ttl", :integer],
      ].each do |name, type|
        install_text_element(name, type)
        install_model(name, '?')
      end

      [
        %w(category categories),
      ].each do |name, plural_name|
        install_have_children_element(name, plural_name)
        install_model(name, '*')
      end
        
      [
        ["image", "?"],
        ["language", "?"],
      ].each do |name, occurs|
        install_model(name, occurs)
      end

      private
      alias children09 children
      def children
        children09 + @category.compact
      end

      alias _tags09 _tags
      def _tags
        rv = %w(generator ttl).delete_if do |name|
          __send__(name).nil?
        end.collect do |elem|
          ["", elem]
        end + _tags09

        @category.each do
          rv << ["", "category"]
        end
        
        rv
      end

      Category = Item::Category

      class Item
      
        [
          ["comments", "?"],
          ["author", "?"],
        ].each do |name, occurs|
          install_text_element(name)
          install_model(name, occurs)
        end

        [
          ["pubDate", '?'],
        ].each do |name, occurs|
          install_date_element(name, 'rfc822')
          install_model(name, occurs)
        end
        alias date pubDate
        alias date= pubDate=

        [
          ["guid", '?'],
        ].each do |name, occurs|
          install_have_child_element(name)
          install_model(name, occurs)
        end

        private
        alias children09 children
        def children
          children09 + [@guid].compact
        end

        alias _tags09 _tags
        def _tags
          %w(comments author pubDate guid).delete_if do |name|
            __send__(name).nil?
          end.collect do |elem|
            ["", elem]
          end + _tags09
        end

        alias _setup_maker_element setup_maker_element
        def setup_maker_element(item)
          _setup_maker_element(item)
          @guid.setup_maker(item) if @guid
        end
        
        class Guid < Element
          
          include RSS09

          [
            ["isPermaLink", "", false, :boolean]
          ].each do |name, uri, required, type|
            install_get_attribute(name, uri, required, type)
          end

          content_setup

          def initialize(*args)
            if Utils.element_initialize_arguments?(args)
              super
            else
              super()
              self.isPermaLink = args[0]
              self.content = args[1]
            end
          end

          alias_method :_PermaLink?, :PermaLink?
          private :_PermaLink?
          def PermaLink?
            perma = _PermaLink?
            perma or perma.nil?
          end

          private
          def maker_target(item)
            item.guid
          end

          def setup_maker_attributes(guid)
            guid.isPermaLink = isPermaLink
            guid.content = content
          end
        end

      end

    end

  end

  RSS09::ELEMENTS.each do |name|
    BaseListener.install_get_text_element("", name, "#{name}=")
  end

end
