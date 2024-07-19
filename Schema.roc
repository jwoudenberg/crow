module [
    Table,

    # Migrations
    Schema,
    Key,
    empty,
    migration,
    dataMigration,

    # Table creation
    Indexes,
    Index,
    table,
    mapTable,
    indexes,
    index,
    unique,
    reference,
]

import pf.Task exposing [Task]

Migration := { fromHash : List U8, toHash : List U8, run : Task {} [] }

Schema s := { migrations : List Migration, schema : Connection -> s }

Connection := {}

Query a := {}

Table a indexes := {
    name : Str,
    columns : List (Column a),
    # To make a query we need the schema and the connection. By storing the
    # connection inside the schema (in every table), the user won't need to
    # pass around two things.
    connection : Connection,
    # Tables can be passed through chains to create queries, so we need to
    # store the query-in-wording here too.
    query : Query a,
}

Column a := {
    name : Str,
    encode : a -> List U8,
    unique : Bool,
    searchable : Bool,
    foreignKey : [Nope, To { table : Str, column : Str }],
}

empty : Schema {}

Key := Connection

migration : Schema old, (Key, old -> new) -> Schema new

dataMigration : Schema s, (s -> Task {} []) -> Schema s

table : Key, Indexes a indexes -> Table a indexes

# Create a new data from an old one
mapTable : Key, Table a *, (a -> b), Indexes a indexes -> Table b indexes

Indexes a indexes := Table a indexes

Index a := {}

indexes : Indexes a k, Indexes a l, (k, l -> m) -> Indexes a m

index : (a -> i) -> Indexes a (Index i)

unique : Indexes a (Index i) -> Indexes a (Index i)

reference :
    Indexes a (Index i),
    Table b indexes,
    (indexes -> Index i)
    -> Indexes a indexes
