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

  it "registers an offense when a deeply nested controller inherits from ApplicationController" do
    expect_offense(<<~RUBY, "app/controllers/api/v1/play_histories_controller.rb")
      module Api
        module V1
          class PlayHistoriesController < ApplicationController
                                          ^^^^^^^^^^^^^^^^^^^^^ Namespaced controllers must inherit from `Api::V1::BaseController` (or `BaseController`), not `ApplicationController`.
          end
        end
      end
    RUBY
  end

  it "registers an offense when a top-level controller inherits from ApplicationController" do
    expect_offense(<<~RUBY, "app/controllers/home_controller.rb")
      class HomeController < ApplicationController
                             ^^^^^^^^^^^^^^^^^^^^^ Only namespaced `BaseController` classes may inherit from `ApplicationController`; move this controller into a namespace.
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

  it "does not register an offense for nested BaseController itself" do
    expect_no_offenses(<<~RUBY, "app/controllers/api/v1/base_controller.rb")
      module Api
        module V1
          class BaseController < ApplicationController
          end
        end
      end
    RUBY
  end

  it "does not register an offense for ApplicationController itself" do
    expect_no_offenses(<<~RUBY, "app/controllers/application_controller.rb")
      class ApplicationController < ActionController::Base
      end
    RUBY
  end
end
