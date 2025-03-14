# Blueit
An attempt at building a link aggregator on top of bluesky (and ideally all of atproto eventually). The name is a pun on reddit. (REDdit -> BLUEit)

## How it works
The basic idea is to rollup all mentions of a specific endopoint (host + path, ignoring scheme and query params) in a bluesky post, and treat the post text as a top level comment on the content.

Each reply to a post with a link on bluesky becomes a reply to the top level comment, and so on to create comment threads.

Upvotes will be based on the number of mentions within a period as well as likes.

## Current Architecture
This is going to be using a daemon to run a rake task that continually streams link data from a jetstream firehose and writes it directly to a timescaledb based hypertable to better support OLAP access.

## TODO
- Either completely remove, or properly gate NSFW content.
- What algorithm to use for upvotes?
  - Link mentions within a time period.
  - Likes on the post with the links.
  - Amount of discussion generated?
  - Allow people to create "topics" (aka subreddits) that filter content and boost particular sites.
- Interaction with the site.
  - Should interaction write to bluesky using their data models that we creatively reinterpret?

### Link cleaning
- How should we handle subdomains?
  - treat www subdomains like they dont exist?
  - Other subdomains might be fine to keep.
- How should we handle query params?
  - Sometimes they dont meaningfully impact what's on the page, other times you can see wildely different content based on the query params.
- How should we handle shortened links?
  - Keep some kind of record of shorted hosts we've seen and what actual domain they map to?
  - Try to follow redirects for links before writting to timeseries table to find the actual domain?
