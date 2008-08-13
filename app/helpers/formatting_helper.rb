module FormattingHelper
  def format_currency( number )
    number_to_currency( number, :unit => '€', :separator => ',', :delimiter => '&thinsp;', :format => '%n&nbsp;%u' )
  end
end