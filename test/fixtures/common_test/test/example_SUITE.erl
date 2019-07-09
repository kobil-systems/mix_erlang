-module(example_SUITE).

-compile(export_all).

-include_lib("stdlib/include/assert.hrl").

all() -> [example_tests].

example_tests(_Config) ->
    2 = 1 + 1,
    ok.
