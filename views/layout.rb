class App
  module Views
    class Layout < Mustache
      def title
        @title || "Mongolog"
      end
    end
  end
end
