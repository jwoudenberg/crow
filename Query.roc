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

    # Text search
    Pattern,
    match,
    contains,
    endsWith,

    # Sorting
    sort,
]

import Schema exposing [Schema, Table, Index]
import pf.Task exposing [Task]

# -- SCHEMA DEFINITION --

# Connect to database expecting a schema.
# - If database has matching schema -> success
# - If database has older schema and migration path exists -> migrate
# - If database has older schema and no migration path exists -> fail
connect : Str, Schema s -> Task s [DbFileNotFound, SchemaMismatch]

## -- QUERYING --

getOne : Table a -> Task a [NoResults, MoreThanOneResult]

getAll : Table a -> Task (List a) *

getCount : Table a -> Task (Int a) *

getUpTo : Table a, Int a -> Task (List a) *

insert : a, Table a -> Task {} [DuplicateKey, ForeignKeyMismatch]

## -- TRANSACTIONS --

transaction : Task a err -> Task a err

## -- FILTERING --
Filter i := {}

where : Table a, Index i a *, Filter i -> Table a

equals : i -> Filter i

lessThan : i -> Filter i

greaterThan : i -> Filter i

in : List i -> Filter i

includes : i -> Filter (List i)

not : Filter i -> Filter i

all : List (Filter i) -> Filter i

any : List (Filter i) -> Filter i

## -- Text Search --
Pattern i := {}

match : Table a, Index i a { searchable : {} }*, Pattern i -> Table a

contains : Str -> Pattern Str

endsWith : Str -> Pattern Str

# -- SORTING --

# In case of multiple sort calls, use later sort as tie-breaker for earlier.
sort : Table a, Index i a *, [Asc, Desc] -> Table a
