%%
%% Copyright (c) 2015-2016 Christopher Meiklejohn.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% @doc Pure GSet CRDT: pure op-based grow-only set.
%%
%% @reference Carlos Baquero, Paulo Sérgio Almeida, and Ali Shoker
%%      Making Operation-based CRDTs Operation-based (2014)
%%      [http://haslab.uminho.pt/ashoker/files/opbaseddais14.pdf]

-module(pure_gset).
-author("Georges Younes <georges.r.younes@gmail.com>").

-behaviour(type).
-behaviour(pure_type).

-define(TYPE, ?MODULE).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-export([new/0, new/1, is_commutative/0]).
-export([mutate/3, query/1, equal/2]).

-export_type([pure_gset/0, pure_gset_op/0]).

-opaque pure_gset() :: {?TYPE, payload()}.
-type payload() :: ordsets:ordset(any()).
-type pure_gset_op() :: {add, pure_type:element()}.

%% @doc Create a new, empty `pure_gset()'
-spec new() -> pure_gset().
new() ->
    {?TYPE, ordsets:new()}.

%% @doc Create a new, empty `pure_gset()'
-spec new([term()]) -> pure_gset().
new([]) ->
    new().

%% check if dt is commutative.
-spec is_commutative() -> boolean().
is_commutative() -> true.

%% @doc Update a `pure_gset()'.
-spec mutate(pure_gset_op(), pure_type:id(), pure_gset()) ->
    {ok, pure_gset()}.
mutate({add, Elem}, _TS, {?TYPE, PureGSet}) ->
    PureGSet1 = {?TYPE, ordsets:add_element(Elem, PureGSet)},
    {ok, PureGSet1}.

%% @doc Returns the value of the `pure_gset()'.
%%      This value is a set with all the elements in the `pure_gset()'.
-spec query(pure_gset()) -> sets:set(pure_type:element()).
query({?TYPE, PureGSet}) ->
    sets:from_list(PureGSet).

%% @doc Equality for `pure_gset()'.
-spec equal(pure_gset(), pure_gset()) -> boolean().
equal({?TYPE, PureGSet1}, {?TYPE, PureGSet2}) ->
    ordsets_ext:equal(PureGSet1, PureGSet2).

%% ===================================================================
%% EUnit tests
%% ===================================================================
-ifdef(TEST).

new_test() ->
    ?assertEqual({?TYPE, ordsets:new()}, new()).

query_test() ->
    Set0 = new(),
    Set1 = {?TYPE, [<<"a">>]},
    ?assertEqual(sets:new(), query(Set0)),
    ?assertEqual(sets:from_list([<<"a">>]), query(Set1)).

add_test() ->
    Set0 = new(),
    {ok, Set1} = mutate({add, <<"a">>}, [], Set0),
    {ok, Set2} = mutate({add, <<"b">>}, [], Set1),
    ?assertEqual({?TYPE, [<<"a">>]}, Set1),
    ?assertEqual({?TYPE, [<<"a">>, <<"b">>]}, Set2).

equal_test() ->
    Set1 = {?TYPE, [<<"a">>]},
    Set2 = {?TYPE, [<<"a">>, <<"b">>]},
    ?assert(equal(Set1, Set1)),
    ?assertNot(equal(Set1, Set2)).

-endif.
