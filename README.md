RubberStamp [![Gem Version](https://badge.fury.io/rb/rubber_stamp.svg)](http://badge.fury.io/rb/rubber_stamp) [![Build Status](https://travis-ci.org/timothycommoner/rubber_stamp.svg?branch=master)](https://travis-ci.org/timothycommoner/rubber_stamp) [![Code Climate](https://codeclimate.com/github/timothycommoner/rubber_stamp/badges/gpa.svg)](https://codeclimate.com/github/timothycommoner/rubber_stamp)
=====================
RubberStamp extends Rails with versioning functionality, including the ability to accept and decline revisions. This gem is inspired by the excellent [PaperTrail](https://github.com/airblade/paper_trail), though with more emphasis on controlling incoming data than simply recording it. This makes RubberStamp ideal for crowd-sourced websites, as contributions and revisions can be reviewed before publication.

Compatibility
-------------

At the moment, RubberStamp only supports Rails 4.

Installation
------------

 1. Add RubberStamp to your gemfile: `gem 'rubber_stamp'`
 2. Run bundler: `bundle install`
 3. Run this in your app folder: `rake rubber_stamp:install:migrations`
 4. Run your migrations: `rake db:migrate`
 5. Add `acts_as_versionable` to the models you want to have controlled versioning
 
Options
-------

By default, RubberStamp will track all attributes except a model's `id`, `created_at`, and `updated_at`. If you want to specify a set of attributes to track, you can do so by passing the `versionable_attributes` argument to `acts_as_versionable`:

    acts_as_versionable versionable_attributes: [:title, :author]
    
Conversely, you can exclude specific attributes (and track everything else):

    acts_as_versionable nonversionable_attributes: [:publication_date]

Finally, if a model is nested within a parent model using `accepts_nested_attributes_for`, you can bundle its revisions with its parent's version by using `nested_within`. Pass in the parent's association name as the sole argument:

    belongs_to :publisher, class_name: "DigitalPublisher"
    acts_as_versionable nested_within: :publisher

Tracking Users and Notes
------------------------

RubberStamp can keep track of both who contributed a revision and any notes they choose to leave about the revision. In both cases, these attributes must be passed in while saving the model.

With users, the simplest approach is to merge the current user into the strong_params hash:

    def my_model_params
      params.require(:novel).permit(:title, :author).merge(user: current_user)
    end

Similarly, if you want the user to leave notes, you should create a textarea for the notes in your form, then permit them in the strong_params hash:

    def my_model_params
      params.require(:novel).permit(:title, :author, :notes)
    end

And that's all you need to track contributor data and notes.

Usage
-----

Create versionable models with the methods `new_with_version` and `create_with_version`:

    def create
      @novel = Novel.new_with_version(novel_params)
      @novel.save
    end

or:

    def create
      @novel = Novel.create_with_version(novel_params)
    end

When you do so, RubberStamp will automatically clone its attributes to create an initial version. You can view this version by calling:

    @novel.initial_version

Versions start out as `pending`, and can be set to `accepted` and `declined`. To accept a version:

    @novel.initial_version.accept

To decline a version:

    @novel.initial_version.decline

When updating a versionable model, you'll need to use `submit_revision` instead of `update_attributes`:

    def update
      @novel = Novel.find(params[id])
      @novel.submit_revision(novel_params)
    end

When using `submit_revision`, your original `@novel` will not be altered. Instead, RubberStamp creates a new version with the submitted revisions. You can then review this submission:

    @novel.versions.last

And either decline it:

    @novel.versions.last.decline

Or accept it:

    @novel.versions.last.accept

If you accept it, then RubberStamp will update the original with your revisions:

    @novel.title # => "fragments from Work in Progress"
    @novel.submit_revision(title: "Finnegans Wake")
    @novel.title # => "fragments from Work in Progress"
    @novel.versions.pending.last.accept
    @novel.title # => "Finnegans Wake"

Examining Changes
-----------------

Before accepting or declining a revision, you'll need to examine it to ensure that the changes are up to your guidelines. You can do so with the `version.revisions` method:

    @novel.submit_revisions(title: "Finnegans Wake")
    version = @novel.versions.last
    changed_attributes = version.revisions.attributes
    changed_attributes.first.name # => "title"
    changed_attributes.first.old_value # => "fragments from Work in Progress"
    changed_attributes.first.new_value # => "Finnegans Wake"

Here we see that `revisions` returns an array of changed attributes. Each of these attributes can be queried for their `name`, `old_value`, and `new_value`. You could use this array to create a table of changes:

    <% version.revisions.attributes.each do |attr| %>
      <th><%= attr.name %></th>
      <td><%= attr.old_value %></td>
      <td><%= attr.new_value %></td>
    <% end %>

In addition to an array of attributes, `revisions` can return an array of nested resources that have been altered:

    @novel.submit_revisions(characters_attributes: [{ id: 7, name: "Shaun" },
      { name: "Shem" },
      { id: 8, _destroy: true }])
    version = @novel.versions.last
    changed_children = version.revisions.children

    changed_children[0].attributes.first.name # => "name"
    changed_children[0].attributes.first.old_value # => "Stanislaus"
    changed_children[0].attributes.first.new_value # => "Shaun"
    
    changed_children[1].attributes.first.name # => "name"
    changed_children[1].attributes.first.old_value # => nil
    changed_children[1].attributes.first.new_value # => "Shem"
    changed_children[1].new? # => true
    
    changed_children[2].marked_for_removal? # => true

In this example, three children are being edited. The first has had his name changed, the second is a new addition, and the third is being removed from the family. If this revision is accepted, then the final child will be deleted from the database, while the second is added to it.

You'll also notice that each child contains an `attributes` hash, just like its parent. They also contain a `children` hash, allowing you to explore deeply nested associations. If you wanted, you could create a recursive table that would represent all changes (on every level) that a version suggests.

Finally, there are two convenience booleans. The first allows you to find out if a child is `new?`. The second checks if a child is `marked_for_removal?`.

Scopes
------

The `Version` model supports three scopes corresponding to the three states a version can be in. They are:

    @novel.versions.pending
    @novel.versions.accepted
    @novel.versions.declined

Version Callbacks
-----------------

Aside from setting internal metadata, RubberStamp does nothing when a version is declined--or when an initial version is accepted. The only time it does something is when a revision is accepted, at which point it updates the versionable.

Most likely, you'll want extra handling in these situations. Perhaps you want to award user reputation points for submitting an acceptable resource. Perhaps you want a resource to be hidden until it has been accepted. Perhaps you want to destroy resources that are declined. You can do all of these things by passing a block to `accept` or `decline`. This block will receive the version in question as its sole parameter.

For instance:

    @resource.accept { |version| version.versionable.make_visible if version.initial? }

Or:

    @resource.decline do |version|
      version.user.deduct_points
      version.versionable.destroy if version.initial?
    end


Issues
------

RubberStamp is still very young, and both its functionality and its documentation are bound to be lacking. If you're having trouble with something, feel free to open an issue.

Contributing
------------

Please! Feel free to send us a pull request. Test new features via Rspec, and try to keep your code simple and readable. Ideally, we'll keep that Code Climate in the green.

Contributors
------------

Timothy Baron

Alternatives
------------

If you don't need the ability to accept or decline content, I'd recommend going with [PaperTrail](https://github.com/airblade/paper_trail), instead. It has a ton of features, as well as support for non-Rails frameworks.

License
-------

Released under the MIT license.