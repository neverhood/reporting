class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :filter_type


  # The idea is to
  def filter_type(value)
    case value.class.name
      when 'Fixnum' then :numeric
      when ('String' || 'Symbol') then :varchar
      when ('Time' || 'Date') then :datetime
      else
        nil
    end
  end

  # We might need some of that
  def guilty_response
    {:text => 'The server understood the request, but is refusing to serve it', :status => 403}
  end

end
