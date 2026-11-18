# frozen_string_literal: true

RSpec.describe RuboCop::Cop::MechaStyleRails::NamespaceBaseController, :config do
  it "registers an offense when a namespaced controller inherits from ApplicationController" do
    expect_offense(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      module Api
        class PlayHistoriesController < ApplicationController
                                        ^^^^^^^^^^^^^^^^^^^^^ Namespaced controllers must inherit from `Api::BaseController` (or `BaseController`), not `ApplicationController`.
        end
      end
    RUBY
  end

  it "does not register an offense when inheriting from Namespace::BaseController" do
    expect_no_offenses(<<~RUBY, "app/controllers/admin/users_controller.rb")
      module Admin
        class UsersController < Admin::BaseController
        end
      end
    RUBY
  end

  it "does not register an offense when inheriting from BaseController inside the namespace" do
    expect_no_offenses(<<~RUBY, "app/controllers/api/play_histories_controller.rb")
      module Api
        class PlayHistoriesController < BaseController
        end
      end
    RUBY
  end

  it "does not register an offense for BaseController itself" do
    expect_no_offenses(<<~RUBY, "app/controllers/api/base_controller.rb")
      module Api
        class BaseController < ApplicationController
        end
      end
    RUBY
  end

  it "does not register an offense for top-level controllers" do
    expect_no_offenses(<<~RUBY, "app/controllers/home_controller.rb")
      class HomeController < ApplicationController
      end
    RUBY
  end
end
