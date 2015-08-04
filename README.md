# ActsAsList

## Description

This is a forked version of [swanandp/acts_as_list](https://github.com/swanandp/acts_as_list). It adds the ability to ignore the default `type` scoping applied to ActiveRecord queries when using single table inheritance models.

To use, simply pass:
```ruby
acts_as_list ignore_sti: true
