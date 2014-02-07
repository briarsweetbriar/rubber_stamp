ControlledVersioning [![Gem Version](https://badge.fury.io/rb/controlled_versioning.png)](http://badge.fury.io/rb/controlled_versioning) [![Build Status](https://travis-ci.org/timothythehuman/controlled_versioning.png?branch=master)](https://travis-ci.org/timothythehuman/controlled_versioning) [![Code Climate](https://codeclimate.com/repos/52f14fbd69568017f9000949/badges/88b0d048286329d8ba82/gpa.png)](https://codeclimate.com/repos/52f14fbd69568017f9000949/feed)
=====================
ControlledVersioning extends Rails with versioning functionality, including the ability to accept and decline revisions. This gem is inspired by the excellent [PaperTrail](https://github.com/airblade/paper_trail), though with more emphasis on controlling incoming data than simply recording it. This makes ControlledVersioning ideal for crowd-sourced websites, as contributions and revisions can be reviewed before publication.

Compatibility
-------------

At the moment, ControlledVersioning only supports Rails 4.

Installation
------------

 1. Add ControlledVersioning to your gemfile: `gem 'controlled_versioning'`
 2. Run this in your app folder: `rails generate controlled_versioning:install:migrations`
 3. Run your migrations: `rake db:migrate`
 4. Add `acts_as_versionable` to the models you want to have controlled versioning
 
Options
-------

By default, ControlledVersioning will track all attributes except a model's `id`, `created_at`, and `updated_at`. If you want to specify a set of attributes to track, you can do so by passing the `versionable_attributes` argument to `acts_as_versionable`:

    acts_as_versionable versionable_attributes: [:title, :author]
    
Conversely, you can exclude specific attributes (and track everything else):

    acts_as_versionable nonversionable_attributes: [:publication_date]

Finally, if a model is nested within a parent model using `accepts_nested_attributes_for`, you can bundle its revisions with its parent's version by using `nested_within`. Pass in the parent's association name as the sole argument:

    belongs_to :publisher, class_name: "DigitalPublisher"
    acts_as_versionable nested_within: :publisher

Tracking Users and Notes
------------------------

ControlledVersioning can keep track of both who contributed a revision and any notes they choose to leave about the revision. In both cases, these attributes must be passed in while saving the model.

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

When you do so, ControlledVersioning will automatically clone its attributes to create an initial version. You can view this version by calling:

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

When using `submit_revision`, your original `@novel` will not be altered. Instead, ControlledVersioning creates a new version with the submitted revisions. You can then review this submission:

    @novel.versions.last

And either decline it:

    @novel.versions.last.decline

Or accept it:

    @novel.versions.last.accept

If you accept it, then ControlledVersioning will update the original with your revisions:

    @novel.title # => "fragments from Work in Progress"
    @novel.submit_revision(title: "Finnegans Wake")
    @novel.title # => "fragments from Work in Progress"
    @novel.versions.pending.last.accept
    @novel.title # => "Finnegans Wake"

Examining Changes
-----------------

WARNING: This output will change drastically before 1.0.0.

Before accepting or declining a revision, you'll need to examine it to ensure that the changes are up to your guidelines. You can do so with the `version.changes` method:

    @novel.versions.last.changes # => { "title" => { old_value: "fragments from Work in Progress", new_value: "Finnegans Wake" }, "author" => { old_value: nil, new_value: "James Joyce" } }

This also works with nested models:

    @novel.versions.last.changes # => { "title" => { old_value: "fragments from Work in Progress", new_value: "Finnegans Wake" }, "publishers" => [{ id: 17, "name": { old_value: "Faber and Faber", new_value: "Farrar, Straus and Giroux" } }, { id: nil, name: { old_value: nil, new_value: "Banton Books" } }, { id: 18, maked_for_removal: true } ] }

In this example, three publishers are being edited. The first has had their name changed, the second is new publisher, and the third has been marked for removal. If this revision is accepted, then the final publisher will be deleted from the database, while the second publisher is added to it.

Scopes
------

The `Version` model supports three scopes corresponding to the three states a version can be in. They are:

    @novel.versions.pending
    @novel.versions.accepted
    @novel.versions.declined