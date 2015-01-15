class HerosController < ApplicationController
  def index
    render_content("Heros!!", "text/text")
  end
end
