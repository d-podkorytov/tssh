-module(tssh).
-compile(export_all).

sh()->sh("127.0.0.1").

sh(Host) when is_list(Host)->
 ssh:start(),
 ssh:shell(Host,22,
 [{silently_accept_hosts, true},
  {user, "root"},
  {password, "toor"}
 ]).

-define(T,io:format("~p:~p ~n",[?MODULE,?LINE])).
-define(T1(Msg),io:format("~p:~p ~p ~n",[?MODULE,?LINE,Msg])).

delay()->timer:sleep(random:uniform(500)+500).

welcome(Msg)->   delay(), Msg.
ask_user(User)-> delay(),"User:"++User.

ask_password(Msg)-> delay(),Msg.

welcome_prompt({IP,Port}, User, Service)->
    {welcome("Trivial SSHD"), ask_user(User), ask_password(":"), false}.
    
% {User,Password} list
users()->[{"root", "toor"}].

start()->listen(22,[%{auth_methods, "publickey,keyboard-interactive,password"},
                    %{subsystems, []},
                    {user_passwords, users()},
                    {connect_timeout,900},
                    {id_string,random},
                    {auth_method_kb_interactive_data, fun(Peer,User,S)-> welcome_prompt(Peer,User,S) end },
                    %{auth_method_kb_interactive_data, {random_welcome(".IDNS_CLI."), "Enter reason for", "sentence: ", false}},
                    {system_dir, "/etc/esshd/"} 
                   ]).

listen(Port) ->    listen(Port, []).

listen(Port, Options) ->
    crypto:start(),
    ssh:start(),
    ssh:daemon(any, Port, [{shell, fun(U, H) -> start_shell(U, H) end} | Options]).

start_shell(User, Peer) ->
    spawn(fun() ->
		  io:setopts([{expand_fun, fun("") -> {yes, "quit", []};
		                              (_) -> {no, "", ["quit","halt","help","exit","?"]} 
                                           end
                              }
		             ]),
		  io:format("~p Date: ~p ~n Nice to meet you,~p from ~p ~n",[random:uniform(99999999999),{date(),time()},User,Peer]),
		  erls_shell_loop(1)
	  end).

erls_shell_loop(N) ->
     Line = io:get_line(atom_to_list(node())++" "++integer_to_list(N)++">"),
     case Line of
      "quit\n"-> exit(self(),normal);
      "exit\n"-> exit(self(),normal);
      "help\n"-> help();
      "halt\n"-> init:stop()
     end,
     io:format("echo: ~p ~n",[Line]),
     erls_shell_loop(N+1).

help()->io:format("~n Help: ~p ~n",[" ? help halt exit quit"]).