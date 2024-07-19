module [
    connect,

    # Querying
    getOne,
    getAll,
    getCount,
    getUpTo,
    insert,
    transaction,

    # Filter
    Filter,
    where,
    not,
    equals,
    lessThan,
    greaterThan,
    in,
    includes,
    all,
    any,
    contains,
    endsWith,

    # Sorting
    sort,
]

import Schema exposing [Schema, Table]
import pf.Task exposing [Task]

# -- SCHEMA DEFINITION --

# Connect to database expecting a schema.
# - If database has matching schema -> success
# - If database has older schema and migration path exists -> migrate
# - If database has older schema and no migration path exists -> fail
connect : Str, Schema s -> Task s [DbFileNotFound, SchemaMismatch]

## -- QUERYING --

getOne : Table a indexes -> Task a [NoResults, MoreThanOneResult]

getAll : Table a indexes -> Task (List a) *

getCount : Table a indexes -> Task (Int a) *

getUpTo : Table a indexes, Int a -> Task (List a) *

insert : Table a indexes, a -> Task {} [DuplicateKey, ForeignKeyMismatch]

## -- TRANSACTIONS --

transaction : Task a err -> Task a err

## -- FILTERING --
Filter i := {}

where : Table a indexes, (indexes -> i), Filter i -> Table a indexes

equals : i -> Filter i

lessThan : i -> Filter i

greaterThan : i -> Filter i

in : List i -> Filter i

includes : i -> Filter (List i)

not : Filter i -> Filter i

all : List (Filter i) -> Filter i

any : List (Filter i) -> Filter i

contains : Str -> Filter Str

endsWith : Str -> Filter Str

# -- SORTING --

# In case of multiple sort calls, use later sort as tie-breaker for earlier.
sort : Table a indexees, (indexes -> i), [Asc, Desc] -> Table a indexes
