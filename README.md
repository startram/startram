# Startram

It's time to take the rails into space...

## Installation

Since crysta doesn't fetch dependencies of dependencies you'll have to add
startrams dependencies on top of startram itself in your `Projectfile`.

```crystal
deps do
  github "spalger/crystal-mime"
  github "dbackeus/activesupport.cr"
  github "dbackeus/startram"
end
```

## Usage

(visionary usage as model layer persistance methods are not actually there from scratch)

```crystal
require "startram"

class User
  include Startram::Model

  field :name, String
  field :age, Integer
end

class UsersController < Startram::Controller
  def index
    @users = User.all

    view :index
  end

  def new
    @user = User.new

    view :new
  end

  def edit
    @user = User.find(params.int("id"))

    view :edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path
    else
      view :new
    end
  end

  def update
    @user = User.find(params.int("id"))

    if @user.update_attributes(user_params)
      redirect_to user_path(@user.id)
    else
      view :edit
    end
  end

  def destroy
    @user = User.find(params.int("id"))

    @user.destroy

    redirect_to users_path
  end

  private def user_params
    User.params(params, :name, :age)
  end
end

app = Startram::App.new(root = __DIR__)

app.router.draw do
  resources :users
end

app.serve

```

## Development

Take advantage of the examples to test your new features.

Run specs as usual with `crystal spec`.

## Contributing

1. Fork it ( https://github.com/dbackeus/startram/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [dbackeus](https://github.com/dbackeus) David Backeus - creator, maintainer
- Various contributions borrowed from Rack, Rails and Amethyst projects
