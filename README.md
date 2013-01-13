## SimpleTag

This is a very simple tagging system for Rails. Because it is so simple, you should fork and modify it for your own purpose.

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

  tagger.tags - tags owned by tagger

### Tag

  tag.taggers - taggers who use this tag
  tag.taggables - records which is tagged with this tag

### Taggable

  taggable.tags - return tags associated with this taggable
  taggable.tags= - set tags of this taggable
  taggable.set_tags - set tags of this taggable
  taggable.add_tags - add more tags to this taggable
  taggable.remove_tags - remove tags of this taggable

  All of these methods (except tags=) can add :context and :tagger as optioanl parameters.
  For example:

  taggable.tags :context => 'skill', :tagger => current_user

  :context and :tagger also accept number as id for faster database query:

  taggable.add_tags, :context => 'skill', :tagger => current_user.id

  If not specified, default context is 'tag' and default tagger is nil.

  Tags should be array of strings, or by default, string with comma(,) to 
  divide tags.
  Delimiter can be specify in :delimiter, for example

  taggable.set_tags 'rails; ruby', :context => 'skill', :delimiter => ';'
  Space, sigle and double quotation will be trimmed automatically.
  For more complicated processing of tag string, use blokc:

  taggable.set_tags 'rails; ruby', :context => 'skill' do |string|
    return string.split(',')
  end

## Acknowledges

SimpleTag is heavily influenced by [rocket_tag](https://github.com/bradphelan/rocket_tag), but not a direct fork.
