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

-module(emqx_rabbitmq_hook_cli).

-include("emqx_rabbitmq_hook.hrl").

-behaviour(ecpool_worker).

-export([connect/0]).

connect() ->
  ConnOpts = #amqp_params_network{
    host = application:get_env(?APP, host),
    port = application:get_env(?APP, port),
    username = application:get_env(?APP, username),
    password = application:get_env(?APP, password)
  },
  {ok, C} = amqp_connection:start(ConnOpts),
  {ok, C}.