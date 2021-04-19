-define(APP, emqx_rabbitmq_hook).

-record(amqp_params_network, {username           = <<"guest">>,
                              password           = <<"guest">>,
                              virtual_host       = <<"/">>,
                              host               = "localhost",
                              port               = undefined,
                              channel_max        = 2047,
                              frame_max          = 0,
                              heartbeat          = 10,
                              connection_timeout = 60000,
                              ssl_options        = none,
                              auth_mechanisms    =
                                  [fun amqp_auth_mechanisms:plain/3,
                                   fun amqp_auth_mechanisms:amqplain/3],
                              client_properties  = [],
                              socket_options     = []}).

-record('P_basic', {content_type, content_encoding, headers, delivery_mode, priority, correlation_id, reply_to, expiration, message_id, timestamp, type, user_id, app_id, cluster_id}).

-record(amqp_msg, {props = #'P_basic'{}, payload = <<>>}).


-record('basic.publish', {ticket = 0, exchange = <<"">>, routing_key = <<"">>, mandatory = false, immediate = false}).