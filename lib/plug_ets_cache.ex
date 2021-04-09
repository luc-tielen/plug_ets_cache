defmodule PlugEtsCache do
  @moduledoc """
  Implements an ETS based cache storage for Plug based applications.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    ttl_check = app_env(:ttl_check, 60)
    con_cache_opts = if ttl_check do
      [
        name: app_env(:db_name, :ets_cache),
        ttl_check_interval: :timer.seconds(ttl_check),
        global_ttl: :timer.seconds(app_env(:ttl, 300))
      ]
    else
      [
        name: app_env(:db_name, :ets_cache),
        ttl_check_interval: false
      ]
    end

    children = [{ConCache, con_cache_opts}]
    opts = [strategy: :one_for_one, name: PlugEtsCache]
    Supervisor.start_link(children, opts)
  end

  defp app_env(key, default) do
    Application.get_env(:plug_ets_cache, key, default)
  end
end
