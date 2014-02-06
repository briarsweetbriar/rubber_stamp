ControlledVersioning [![Gem Version](https://badge.fury.io/rb/controlled_versioning.png)](http://badge.fury.io/rb/controlled_versioning) [![Build Status](https://travis-ci.org/timothythehuman/controlled_versioning.png?branch=master)](https://travis-ci.org/timothythehuman/controlled_versioning) [![Code Climate](https://codeclimate.com/repos/52f14fbd69568017f9000949/badges/88b0d048286329d8ba82/gpa.png)](https://codeclimate.com/repos/52f14fbd69568017f9000949/feed)
=====================
ControlledVersioning adds model versioning to a Rails app, with the ability to accept and decline revisions before actually persisting them to the database. This gem is inspired by the excellent [PaperTrail](https://github.com/airblade/paper_trail), though with more emphasis on controlling data than recording it.

Compatibility
-------------

At the moment, ControlledVersioning only supports Rails 4.

Installation
------------

 1. Add ControlledVersioning to your gemfile: `gem 'controlled_versioning'`
 2. Run this in your app folder: `rails generate controlled_versioning:install`
 3. Run your migrations: `rake db:migrate`
 4. Add `acts_as_versionable` to the models you want to have controlled versioning
 
Options
-------

By default, ControlledVersioning will track all attributes except a model's `id`, `created_at`, and `updated_at`. If you want to specify a set of attributes to track, you can do so by passing the `versionable_attributes` argument to `acts_as_versionable`:

    acts_as_versionable versionable_attributes: [:some_attribute, :some_other_attribute]
    
Conversely, you can exclude specific attributes (and track everything else):

    acts_as_versionable nonversionable_attributes: [:some_attribute, :some_other_attribute]

Finally, if a model is nested within a parent model using `accepts_nested_attributes_for`, you can bundle its revisions with its parent's version by using `nested_within`. Pass in the parent's association name as the sole argument:

    belongs_to :my_parent, class_name: "ParentModel"
    acts_as_versionable nested_within: :my_parent

Tracking Users and Notes
------------------------

ControlledVersioning can keep track of both who contributed a revision and any notes they choose to leave about the revision. In both cases, these attributes must be passed in while saving the model.

With users, the simplest approach is to merge the current user into the strong_params hash:

    def my_model_params
      params.require(:my_model).permit(:some_attribute, some_other_attribute).merge(user: current_user)
    end

Similarly, if you want the user to leave notes, you should create a textarea for the notes in your form, then permit them in the strong_params hash:

    def my_model_params
      params.require(:my_model).permit(:some_attribute, some_other_attribute, :notes)
    end

And that's all you need to track contributor data and notes.

Usage
-----

Create versionable models as usual:

    def create
      @my_model = MyModel.create(my_model_params)
    end

When you do so, ControlledVersioning will automatically clone its attributes to create an initial version. You can view this version by calling:

    @my_model.initial_version

Versions start out as `pending`, and can be set to `accepted` and `declined`. To accept a version:

    @my_model.initial_version.accept

To decline a version:

    @my_model.initial_version.decline

When updating a versionable model, you'll need to use `submit_revision` instead of `update_attributes`:

    def create
      @my_model = MyModel.find(params[id])
      @my_model.submit_revision(my_model_params)
    end

When using `submit_revision`, your original `@my_model` will not be altered. Instead, ControlledVersioning creates a new version with the submitted revisions. You can then review this submission:

    @my_model.versions.last

And either decline it:

    @my_model.versions.last.decline

Or accept it:

    @my_model.versions.last.accept

If you accept it, then ControlledVersioning will update the original with your revisions:

    @my_model.title # => "fragments from Work in Progress"
    @my_model.submit_revision(title: "Finnegans Wake")
    @my_model.title # => "fragments from Work in Progress"
    @my_model.versions.last.accept
    @my_model.title # => "Finnegans Wake"