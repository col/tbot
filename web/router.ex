defmodule Tbot.Router do
  use Tbot.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Tbot do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/telegram", Tbot do
    pipe_through :api

    get "/message", TelegramMessageController, :show
    post "/message", TelegramMessageController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", Tbot do
  #   pipe_through :api
  # end
end
