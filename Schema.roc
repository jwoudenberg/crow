module [
    Schema,
    Table,
    Index,
    ForeignKey,
    Regular,
    Unique,
    Search,
    empty,
    migration,
    dataMigration,
    table,
    index,
    uniqueIndex,
    searchIndex,
    foreignKey,
]

import pf.Task exposing [Task]

Migration := { fromHash : List U8, toHash : List U8, run : Task {} [] }

Schema s := { migrations : List Migration, schema : Connection -> s }

Connection := {}

Key := Connection

Table a := { name : List U8 }

Index t a i := {
    table : List U8,
    index : List U8,
    kind : [Regular, Unique, Search],
    calculate : a -> i,
}

ForeignKey a b := {
    sourceTable : List U8,
    sourceIndex : List U8,
    targetTable : List U8,
    targetIndex : List U8,
}

Regular := {}
Unique := {}
Search := {}

empty : Schema {}

migration : Schema old, (Key, old -> new) -> Schema new

dataMigration : Schema s, (s -> Task {} []) -> Schema s

table : Key -> Table a

index : Key, Table a, (a -> i) -> Index Regular a i

uniqueIndex : Key, Table a, (a -> i) -> Index Unique a i

searchIndex : Key, Table a, (a -> Str) -> Index Search a Str

foreignKey : Key, Index _ a i, Index Unique b i -> ForeignKey a b
