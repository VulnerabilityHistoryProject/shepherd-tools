require_relative 'helper'

describe VHP::StringRefinements do
  using VHP::StringRefinements

   context :strip_heredoc do
     it 'strips heredocs properly' do
       str = <<-FOO
         A
           B
             C
         D
       FOO
       expect(str.strip_heredoc).to eq("A\n  B\n    C\nD\n")
     end

     it 'uses the syntax I expect' do
       str = <<-FOO.strip_heredoc
         A
           B
       FOO
       expect(str).to eq("A\n  B\n")
     end
   end
end
