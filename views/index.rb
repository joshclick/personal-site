class App
  module Views
    class Index < Layout
      def posts
        @posts || "Welcome! Mustache lives."
      end
    end
  end
end
