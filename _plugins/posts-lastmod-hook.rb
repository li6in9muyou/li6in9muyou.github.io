#!/usr/bin/env ruby
#
# Check for changed posts and set last_modified_at

Jekyll::Hooks.register :posts, :post_init do |post|
  # Always try to get the last commit date for the file
  begin
    # Get the last commit date for this specific file
    lastmod_date = `git log -1 --pretty="%ad" --date=iso "#{ post.path }" 2>/dev/null`.strip
    
    if lastmod_date && !lastmod_date.empty?
      post.data['last_modified_at'] = lastmod_date
    else
      # Fallback to post date if no git history
      post.data['last_modified_at'] = post.date.iso8601
    end
  rescue => e
    # If git command fails, use post date as fallback
    post.data['last_modified_at'] = post.date.iso8601
  end
end
