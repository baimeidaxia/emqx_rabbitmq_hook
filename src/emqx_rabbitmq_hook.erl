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
-include("include/emqx_rabbitmq_hook.hrl").

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

    ClientInfo2 = ClientInfo#{peerhost := ip_to_binary(maps:get(peerhost, ClientInfo))},
    ConnInfo2 = ConnInfo#{peername := ip_port_to_binary(maps:get(peername, ConnInfo)), sockname := ip_port_to_binary(maps:get(sockname, ConnInfo))},

    publish_message("client.connected", #{ clientInfo => ClientInfo2, connInfo => ConnInfo2}).

on_client_disconnected(ClientInfo = #{clientid := ClientId}, ReasonCode, ConnInfo, _Env) ->
    io:format("Client(~s) disconnected due to ~p, ClientInfo:~n~p~n, ConnInfo:~n~p~n",
              [ClientId, ReasonCode, ClientInfo, ConnInfo]).
    % publish_message("disconnected").

%% Called when the plugin application stop
unload() ->
    emqx:unhook('client.connected',    {?MODULE, on_client_connected}),
    emqx:unhook('client.disconnected', {?MODULE, on_client_disconnected}).

publish_message(RoutingKey, Payload) ->
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

    Publish = #'basic.publish'{exchange = <<"t.jxp">>, routing_key = list_to_binary(RoutingKey) },
    amqp_channel:cast(Channel, Publish, #amqp_msg{payload = jiffy:encode(Payload) }),

    amqp_connection:close(Connection),
    io:format("closed amqp connection \n").

ip_to_binary(IpTuple) ->
    list_to_binary(ip_to_string(IpTuple)).

ip_to_string(IpTuple) ->
    string:join(lists:map(fun(X)-> integer_to_list(X) end, tuple_to_list(IpTuple)), ".").

ip_port_to_binary(IpPortTuple) ->
    {IP_Tuple, Port} = IpPortTuple,
    IpStr = ip_to_string(IP_Tuple),
    PortStr = integer_to_list(Port),
    list_to_binary(string:join([IpStr, PortStr], ":")).