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
import Blob

Migration : {
    hash : List U8,
    run : Task {} [],
}

Schema s := Connection -> { migrations : List Migration, schema : s }

Connection := {}

Key := Connection

Query a := [EmptyQuery]

Table a indexes := {
    name : Str,
    indexrecord : indexes,
    columns : List (Column a),
    # To make a query we need the schema and the connection. By storing the
    # connection inside the schema (in every table), the user won't need to
    # pass around two things.
    connection : Connection,
    # Tables can be passed through chains to create queries, so we need to
    # store the query-in-wording here too.
    query : Query a,
}

Column a : {
    encode : a -> List U8,
    spec : ColumnSpec,
}

ColumnSpec : {
    type : [Integer, Real, Text, Blob],
    index : [NoIndex, Index IndexDesc],
}

empty : Schema {}
empty = @Schema \_ -> {
    migrations: [],
    schema: {},
}

migration : Schema old, (Key, old -> new) -> Schema new
migration = \@Schema getSchema, update ->
    @Schema \connection ->
        { schema, migrations } = getSchema connection

        newSchema = update (@Key connection) schema

        newMigration = {
            run: Task.forEach
                (diffSchema schema newSchema)
                (\change -> applySchemaChange connection change),
            hash: hashSchema newSchema,
        }

        {
            schema: newSchema,
            migrations: List.append migrations newMigration,
        }

SchemaChange : [
    AddTable { name : Str, columns : List ColumnSpec },
    RemoveTable { name : Str },
    MigrateData { run : Connection -> Task {} [] },
]

IndexDesc : {
    unique : Bool,
    foreignKey : [
        NoForeignKey,
        ForeignKey { table : Str, column : U64 },
    ],
}

diffSchema : old, new -> List SchemaChange
diffSchema = \_, _ ->
    crash "unimplemented: requires type hashing"

applySchemaChange : Connection, SchemaChange -> Task {} []
applySchemaChange = \connection, change ->
    when change is
        AddTable _ -> crash "unimplemented: requires db effects"
        RemoveTable _ -> crash "unimplemented: requires db effects"
        MigrateData { run } -> run connection

dataMigration : Schema s, (s -> Task {} []) -> Schema s
dataMigration = \@Schema getSchema, run ->
    @Schema \connection ->
        { schema, migrations } = getSchema connection

        newMigration = {
            run: run schema,
            hash: hashSchema schema,
        }

        {
            schema,
            migrations: List.append migrations newMigration,
        }

hashSchema : s -> List U8
hashSchema = \_ -> crash "unimplemented: requires type hashing"

Phantom a := {}

# TODO: figure out how I'm going to deal with recursive types.
hashType : Phantom s -> Str
hashType = \_ -> crash "unimplemented: requires type hashing"

table : Key, Indexes a indexes -> Table a indexes
table = \@Key connection, @Indexes { columns, indexrecord } ->
    mainColumn = {
        encode: Blob.encode,
        spec: {
            type: Blob,
            index: NoIndex,
        },
    }

    query : Query a
    query = @Query EmptyQuery

    typePhantom : Phantom a
    typePhantom = @Phantom {}

    @Table {
        name: hashType typePhantom,
        indexrecord,
        connection,
        query,
        columns: List.prepend columns mainColumn,
    }

# Create a new data from an old one
mapTable : Key, Table a *, (a -> b), Indexes a indexes -> Table b indexes

Indexes a indexes := {
    # 'columns' is used to encode new values inserted into a table.
    columns : List (Column a),
    # 'indexes' supports querying indexes using where statements.
    indexrecord : indexes,
}

# TODO: allow this type to describe joins
Index a := U64

# TODO: figure out how to implement this function without getting a compiler error
recreateColumn : Column a -> Column a

indexes : Indexes a k, Indexes a l, (k, l -> m) -> Indexes a m
indexes = \@Indexes index1, @Indexes index2, map2 ->
    columns1 = List.map index1.columns recreateColumn
    columns2 = List.map index2.columns recreateColumn
    @Indexes {
        columns: List.concat columns1 columns2,
        indexrecord: map2 index1.indexrecord index2.indexrecord,
    }

index : (a -> i) -> Indexes a (Index i)
index = \select ->
    # TODO: specialize column type if it is a primitive type.
    @Indexes {
        # TODO: get incremental index
        indexrecord: @Index 0,
        columns: [
            {
                encode: \row -> Blob.encode (select row),
                spec: {
                    type: Blob,
                    index: NoIndex,
                },
            },
        ],
    }

unique : Indexes a (Index i) -> Indexes a (Index i)
unique = \@Indexes { columns, indexrecord } ->
    updateIndex = \ix ->
        when ix is
            NoIndex ->
                Index {
                    unique: Bool.true,
                    foreignKey: NoForeignKey,
                }

            Index desc ->
                Index { desc & unique: Bool.true }

    @Indexes {
        indexrecord,
        columns: columns
        |> List.map \column ->
            spec = column.spec
            { column & spec: { spec & index: updateIndex spec.index } },
    }

reference :
    Indexes a (Index i),
    Table b indexes,
    (indexes -> Index i)
    -> Indexes a indexes
reference = \@Indexes { columns, indexrecord }, @Table foreignTable, getForeignIndex ->
    foreignKey =
        ForeignKey {
            table: foreignTable.name,
            column: foreignTable.indexrecord
            |> getForeignIndex
            |> \@Index i -> i,
        }

    updateIndex = \ix ->
        when ix is
            NoIndex ->
                Index {
                    unique: Bool.false,
                    foreignKey,
                }

            Index desc ->
                Index { desc & foreignKey }

    @Indexes {
        indexrecord: foreignTable.indexrecord,
        columns: columns
        |> List.map \column ->
            spec = column.spec
            { column & spec: { spec & index: updateIndex spec.index } },
    }

