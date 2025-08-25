#!/usr/bin/env ruby
#
# Custom posts sorting plugin
# Sort posts by last_modified_at (if available) or date, newest first

Jekyll::Hooks.register :site, :after_init do |site|
  # Sort posts by last_modified_at (if available) or date, newest first
  site.posts.sort_by! do |post|
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
