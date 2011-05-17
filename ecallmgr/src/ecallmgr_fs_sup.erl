%%%-------------------------------------------------------------------
%%% @author James Aimonetti <james@2600hz.org>
%%% @copyright (C) 2011, VoIP INC
%%% @doc
%%% Manage starting fs_auth, fs_route, and fs_node handlers
%%% @end
%%% Created : 17 May 2011 by James Aimonetti <james@2600hz.org>
%%%-------------------------------------------------------------------
-module(ecallmgr_fs_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_handler/2]).

%% Supervisor callbacks
-export([init/1]).

-include("ecallmgr.hrl").

-define(SERVER, ?MODULE).
-define(CHILD(Name, Mod, Args), {Name, {Mod, start_link, Args}, temporary, 5000, worker, [Mod]}).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

-spec(start_handler/2 :: (Node :: atom(), Options :: proplist()) -> list(tuple(ok, pid()))).
start_handler(Node, Options) when is_atom(Node) ->
    NodeB = whistle_util:to_binary(Node),
    [ begin
	  Name = whistle_util:to_atom(<<NodeB/binary, H/binary>>, true),
	  Mod = whistle_util:to_atom(<<"ecallmgr_fs", H/binary>>),
	  supervisor:start_child(?SERVER, ?CHILD(Name, Mod, [Node, Options]))
      end
      || H <- [<<"_auth">>, <<"_node">>, <<"_route">>] ].


%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @spec init(Args) -> {ok, {SupFlags, [ChildSpec]}} |
%%                     ignore |
%%                     {error, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1,
    MaxSecondsBetweenRestarts = 5,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    {ok, {SupFlags, []}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
