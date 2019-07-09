-module(example_error).

-ifdef(EUNIT).
-compile(export_all).

-include_lib("eunit/include/eunit.hrl").
-endif.

-export([foo/2]).

foo(A, B) -> A + B.

-ifdef(EUNIT).
foo_test() ->
    ?assertEqual(3, foo(1, 2)).
-endif.
