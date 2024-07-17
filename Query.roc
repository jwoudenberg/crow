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
    contains,
    like,
    endsWith,
    all,
    any,
    sort,

    # Joins
    Join,
    join,
    getJoin,
    source,
    inner,
    outer,
    reverse,
    chain,
]

import Schema exposing [Schema, Table, Index, ForeignKey, Search]
import pf.Task exposing [Task]

Filter t i := {}

Join a state := {}

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

where : Table a, Index t a i, Filter t i -> Table a

equals : i -> Filter t i

lessThan : i -> Filter t i

greaterThan : i -> Filter t i

in : List i -> Filter t i

contains : i -> Filter t (List i)

like : Str -> Filter Search Str

endsWith : Str -> Filter Search Str

not : Filter t i -> Filter t i

all : List (Filter t i) -> Filter t i

any : List (Filter t i) -> Filter t i

# -- SORTING --

# In case of multiple sort calls, use later sort as tie-breaker for earlier.
sort : Table a, Index _ a i, [Asc, Desc] -> Table a

# -- JOINS --
#
#    recipes : Table Recipe
#    authors : Table Author
#    ingredients : Table Ingredient
#
#    recipeIngredients : ForeignKey Ingredient Recipe
#    recipeAuthor : ForeignKey Recipe Author
#
#    { recipes, authors, ingredients } =
#        { join <-
#            recipes: source recipes
#            authors: inner recipeAuthor,
#            ingredients: outer (reverse recipeIngredients),
#        } |> getJoin!
#

join : Join a (s -> t), Join a s -> Join a state

source : Table a -> Join a state

inner : ForeignKey a b -> Join a state

outer : ForeignKey a b -> Join a state

getJoin : Join a state -> Task state []

reverse : ForeignKey a b -> ForeignKey b a

chain : ForeignKey a b, ForeignKey b c -> ForeignKey a c
