## SimpleTag

This is a very simple tagging system for Rails. Because it is so simple, you should fork and modify it for your own purpose.

This gem is used in my other projects, thus, it will be kept updated, albeit slowly.

## Install

    rails generate simple_tag:migration
    rake db:migrate
    rake db:test:prepare

## Basic Usage

  SimpleTag offers very few methods to manipulate tags. You mostly work
  on adding and removing tags on taggable. For advanced usage, try
  work on the assocation of SimpleTag models, or fork this project
  and extend its functionality.

### Tagger

  You need to define __acts_as_tagger__ in tagger model like this:

    class User < ActiveRecord::Base
      acts_as_tagger
    end

  Only **ONE** model can be tagger.

  You can find tags of tagger:

    tagger.tags

  Tags in a context can be retrieved like this:

    tagger.tags.in_context(:skill)

### Taggable
  
  You need to define __acts_as_taggable__ in tagger model like this:

    class Post < ActiveRecord::Base
      acts_as_taggable
    end

  You can manage tags of taggable

    taggable.tags: return tags associated with this taggable
    taggable.tags=: set tags of this taggable without context and tagger
    taggable.set_tags: set tags of this taggable and remove old tags

  All of setting methods (except tags=) can add :context and :tagger as optioanl parameters.
  For example:

    taggable.set_tags ['ruby', 'rvm'], :context => 'skill', :tagger => current_user

  :context and :tagger also accept number as id for faster database query:

    taggable.set_tags, :context => 'skill', :tagger => current_user.id

  If not specified, default context is nil and default tagger is nil.

  Tags should be an array of strings, or by default, a string with comma(,) to 
  divide tags.
  Delimiter can be specified in :delimiter, for example:

    taggable.set_tags 'rails; ruby', :context => 'skill', :delimiter => ';'

  Space, single and double quotation will be trimmed automatically.
  For more complicated processing of tag string, use block:

    taggable.set_tags 'rails; ruby', :context => 'skill' do |tag_list|
      return tag_list.split(',')
    end

  To retrieve tags in a context, use

    taggable.tags.in_context(:skill)

  To retreieve tags tagged by a tagger, use

    taggable.tags.by_tagger(User.first)

  __in_context__ and __by_tagger__ can be chained together. They are methods in scopes.

  To retrieve taggable tagged with tags, use

    Taggable.with_tags('ruby, rvm', :match => :any)

  Options for __:match__ can be :any (default), :all (expensive).

  __with_tags__ can also be used with __in_context__ and __by_tagger__

  To delete tags, set __nil__:

    taggable.set_tags(nil)

  To delete tags associated with context and tagger, include options __context__ and __tagger__:

    taggable.set_tags(nil, :context => :skill, :tagger = User.first)

### Tag

    tag.taggers: taggers who use this tag
    tag.taggings.collect(&:taggable): array of taggable tagged with this tag

  To retrieve tags in a context, use

    tags.in_context(:skill)

  To retreieve tags tagged by a tagger, use

    tagger.tags

### Tagging

  No public methods for now. 

  This is the core model to link together tag, context, taggable and tagger. 
  If you need to work on low-level database query, you probably need to look
  at this one.

### Tag Context

  No public methods for now.

  Just a place to keep records on tag context.

## FAQ

#### How do I get tag list from returned SimpleTag::Tag ?

    tags.pluck(:name).join(', ')


#### What's the difference between these two ?

    user.posts.tags

    user.posts.by_tagger(user)


The first returns all tags associated with posts, including tags tagged by others. The second return all tags associated with posts AND tagged by tagger.

#### What's the difference between these two ?

    Post.with_tags('ruby')

    Post.with_tags('ruby').in_context(nil)

The first returns all tags with 'ruby', regardless the context. In another word, it return all taggables with any context. The second returns all tags with 'ruby' with nil context. In another word, it will not return taggables where context exists. The same idea applies to __by_tagger__.

## Acknowledges

SimpleTag is heavily influenced by [rocket_tag](https://github.com/bradphelan/rocket_tag), but not a direct fork.

## License

MIT
