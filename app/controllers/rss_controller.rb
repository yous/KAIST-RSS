class RssController < ApplicationController
  def index
    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end
end
