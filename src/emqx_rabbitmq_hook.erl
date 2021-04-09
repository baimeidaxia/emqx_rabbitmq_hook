%%--------------------------------------------------------------------
%% Copyright (c) 2020 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_rabbitmq_hook).

-include_lib("emqx/include/emqx.hrl").
-include("../amqp_client/include/amqp_client.hrl").

-export([ load/1
        , unload/0
        ]).

%% Client Lifecircle Hooks
-export([ on_client_connected/3
        , on_client_disconnected/4
        ]).

%% Called when the plugin application start
load(Env) ->
    emqx:hook('client.connected',    {?MODULE, on_client_connected, [Env]}),
    emqx:hook('client.disconnected', {?MODULE, on_client_disconnected, [Env]}).

%%--------------------------------------------------------------------
%% Client Lifecircle Hooks
%%--------------------------------------------------------------------

on_client_connected(ClientInfo = #{clientid := ClientId}, ConnInfo, _Env) ->
    io:format("Client(~s) connected, ClientInfo:~n~p~n, ConnInfo:~n~p~n",
              [ClientId, ClientInfo, ConnInfo]),
    publish_message("connented").

on_client_disconnected(ClientInfo = #{clientid := ClientId}, ReasonCode, ConnInfo, _Env) ->
    io:format("Client(~s) disconnected due to ~p, ClientInfo:~n~p~n, ConnInfo:~n~p~n",
              [ClientId, ReasonCode, ClientInfo, ConnInfo]),
    publish_message("disconnected").

%% Called when the plugin application stop
unload() ->
    emqx:unhook('client.connected',    {?MODULE, on_client_connected}),
    emqx:unhook('client.disconnected', {?MODULE, on_client_disconnected}).

publish_message(Message) ->
    application:ensure_started(amqp_client),

    {ok, Connection} =
	amqp_connection:start(#amqp_params_network{host =
						       "192.168.1.200",
						   port = 5672,
						   username = <<"bss">>,
						   password =
						       <<"junfang123">>}),
    io:format("created amqp connection \n"),

    {ok, Channel} = amqp_connection:open_channel(Connection),
    io:format("opened amqp connection channel \n"),

    Payload = <<Message>>,
    Publish = #'basic.publish'{exchange = <<"t.jxp">>, routing_key = <<"*">>},
    amqp_channel:cast(Channel, Publish, #amqp_msg{payload = Payload}),

    amqp_connection:close(Connection),
    io:format("closed amqp connection \n").