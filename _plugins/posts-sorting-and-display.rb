#!/usr/bin/env ruby
#
# Custom posts sorting and display plugin
# This plugin modifies the default Jekyll behavior to:
# 1. Sort posts by last_modified_at (if available) or date, newest first
# 2. Ensure last_modified_at is available for display

Jekyll::Hooks.register :site, :post_read do |site|
  # Sort posts by last_modified_at (if available) or date, newest first
  site.posts.docs.sort_by! do |post|
    # Use last_modified_at if available, otherwise fall back to date
    lastmod = post.data['last_modified_at']
    if lastmod
      # Parse the ISO date string and convert to Time object
      Time.parse(lastmod)
    else
      # Fall back to post date
      post.date
    end
  end.reverse! # Reverse to get newest first
end

# Ensure last_modified_at is available for all posts
Jekyll::Hooks.register :posts, :post_init do |post|
  # If last_modified_at is not set, use the post date as fallback
  unless post.data['last_modified_at']
    post.data['last_modified_at'] = post.date.iso8601
  end
end
