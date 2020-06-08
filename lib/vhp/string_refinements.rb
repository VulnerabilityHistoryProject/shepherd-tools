module VHP
  module StringRefinements
    refine String do
      # Remove all leading whitespace up to the least-indented heredoc
      # Stolen from ActiveSupport, (MIT-licensed, so not stealing)
      def strip_heredoc
        gsub(/^#{scan(/^[ \t]*(?=\S)/).min}/, "").tap do |stripped|
          stripped.freeze if frozen?
        end
      end
    end
  end
end
