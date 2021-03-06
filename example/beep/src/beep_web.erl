-module(beep_web).
-author('Dave Bryson <http://weblog.miceda.org>').
-export([start/1, stop/0, loop/1, before_filter/1, before_render/2]).

-include("rberl.hrl").


start(Options) ->
	application:start(ssl),
	rberl_server:start(),
	rberl_server:load("priv/", "lang"),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req) ->
	Mod = ewgi_mochiweb:new(beepbeep:loop([beepbeep_session, beep_web_dispatch, beepbeep])),
    Mod:run(Req).

%% If necessary, add these hooks:
%% *DON'T FORGET TO EXPORT THEM AS NECESSARY*

%% before_filter/1
%%
%% Should return one of:
%% ok
%% {render, View, Data}
%% {render, View, Data, Options}
%% {static, File}
%% {text, Data}
%% {redirect, Url}
%% {controller, ControllerName}
%% {controller, ControllerName, ActionName}
%% {controller, ControllerName, ActionName, Args}
%%
before_filter(Context) ->
	ok.

%% before_render/2
%%
%% This hook accepts one of these tuples:
%% {render, View, Data}
%% {render, View, Data, Options}
%% {static, File}
%% {text, Data}
%%
%% Should return one of:
%% {render, View, Data}
%% {render, View, Data, Options}
%% {static, File}
%% {text, Data}
%% {redirect, Url}
%%
before_render({render, View, Data, Options}, Env) ->
	Language = ewgi_api:find_data("beep_web.language", Env, "en-US"),
	PathInfo = ewgi_api:path_info(Env),

	Languages = lists:filter(fun(T) -> T =/= Language end, ?LANGUAGES),

	{render, View, Data ++ [
		 {list_to_atom("menu_link_" ++ ewgi_api:find_data("beep.controller", Env, "")), true}
		,{language, Language}
		,{languages, Languages}
		,{path, PathInfo}
		,?TXT("menu_home")
		,?TXT("menu_download")
		,?TXT("menu_documentation")
		,?TXT("menu_faq")
		,?TXT("seo_keywords")
		,?TXT("seo_description")
	], Options}.
%%
%% error/2
%%
%% Catch some errors:
%%
%% Should return one of:
%% {error, Reason}
%% {render, View, Data}
%% {render, View, Data, Options}
%% {static, File}
%% {text, Data}
%% {redirect, Url}
%%
%% error({error, _Reason} = Error, _Env) ->
%%	Error.