module [
    connect,

    # Querying
    getOne,
    getAll,
    getCount,
    getUpTo,

    # Mutation
    insert,
    delete,
    transaction,

    # Filter
    Filter,
    where,
    not,
    equals,
    lessThan,
    greaterThan,
    in,
    inResults,
    includes,
    all,
    any,
    contains,
    startsWith,
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

getOne : Table a * -> Task a [IOError, NoResults, MoreThanOneResult]

getAll : Table a * -> Task (List a) [IOError]

getCount : Table a * -> Task (Int *) [IOError]

getUpTo : Table a *, Int a -> Task (List a) [IOError]

## -- MUTATION --

insert : Table a *, List a -> Task {} [IOError, DuplicateKey, ForeignKeyMismatch]

delete : Table a * -> Task a err

transaction : Task a err -> Task a err

## -- FILTERING --
Filter i := {}

where :
    Table a indexes,
    (indexes -> Index i),
    Filter i
    -> Table a indexes

equals : i -> Filter i

lessThan : i -> Filter i

greaterThan : i -> Filter i

in : List i -> Filter i

inResults : Table a indexes, (indexes -> Index i) -> Filter i

includes : i -> Filter (List i)

not : Filter i -> Filter i

all : List (Filter i) -> Filter i

any : List (Filter i) -> Filter i

contains : Str -> Filter Str

startsWith : Str -> Filter Str

endsWith : Str -> Filter Str

# -- SORTING --

# In case of multiple sort calls, use later sort as tie-breaker for earlier.
sort : Table a indexees, (indexes -> Index i), [Asc, Desc] -> Table a indexes
