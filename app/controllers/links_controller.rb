class LinksController < ApplicationController
  def index
    @links = Link.unscoped.link_post_counts.order(count: :desc).limit(100)
  end
end
