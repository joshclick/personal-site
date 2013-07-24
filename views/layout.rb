class App
  module Views
    class Layout < Mustache
      def title
        @title || "Title Here"
      end
    end
  end
end
