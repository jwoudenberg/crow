module [
    Table,
    table,

    # Migrations
    Schema,
    empty,
    migration,
    dataMigration,

    # Indexes
    index,
    unique,
    references,
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

migration : Schema old, (old -> new) -> Schema new

dataMigration : Schema s, (s -> Task {} []) -> Schema s

table : Table a k, Table a l, (k, l -> m) -> Table a m

index : (a -> i) -> Table a i

unique : Table a i -> Table a i

references :
    Table a i,
    Table b indexes,
    (indexes -> i)
    -> Table a b
