module [
    Table,
    table,

    # Migrations
    Schema,
    empty,
    migration,
    dataMigration,

    # Indexes
    Index,
    index,
    unique,
    searchable,

    # Foreign keys
    ForeignKey,
    foreignKey,
]

import pf.Task exposing [Task]

Migration := { fromHash : List U8, toHash : List U8, run : Task {} [] }

Schema s := { migrations : List Migration, schema : Connection -> s }

Connection := {}

Key := Connection

Table a := { name : List U8 }

Index i a t := {
    table : List U8,
    index : List U8,
    unique : Bool,
    searchable : Bool,
    calculate : a -> i,
}

ForeignKey a b := {
    sourceTable : List U8,
    sourceIndex : List U8,
    targetTable : List U8,
    targetIndex : List U8,
}

empty : Schema {}

migration : Schema old, (Key, old -> new) -> Schema new

dataMigration : Schema s, (s -> Task {} []) -> Schema s

table : Key -> Table a

index : Key, Table a, (a -> i) -> Index i a {}

unique : Index i a {}t -> Index i a { unique : {} }t

searchable : Index i a {}t -> Index i a { searchable : {} }t

foreignKey :
    Key,
    Index i a *,
    Index i b { unique : {} }*
    -> ForeignKey a b
