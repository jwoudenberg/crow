app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.12.0/Lb8EgiejTUzbggO2HVVuPJFkwvvsfW6LojkLR20kTVE.tar.br" }

import Schema
import Query

import pf.Task exposing [Task]
import pf.Stdout

main =
    # When connecting to the database crow checks the version of the database
    # schema, and if necessary runs migrations to bring it to the latest.
    db = Query.connect! "./my-database.crow" latest

    # We can only query indexes. Any other type of filtering we'll have to do
    # on the data we get back from the database.
    roc =
        db.langs
            |> Query.where db.langName (Query.equals "Roc")
            |> Query.getOne!
    description = Str.joinWith roc.tags ", "
    Stdout.line! "Roc is all these things: ${description}"

# -- schema migrations --

# Migrations form a chain, each one taking the schema created by the previous
# migration and returning an updated schema. By convention we call the most
# recent migration 'latest'.
latest = Schema.migration migration2 \key, { langs, langId, langName } ->
    people : Schema.Table { id : U64, name : Str, favoriteLang : U64 }
    people = Schema.table key
    favoriteLang =
        Schema.index key people .favoriteLang
        |> Schema.foreignKey langId
    { langs, langId, langName, people, favoriteLang }

# Data migrations modify the data in the database but don't modify the schema.
# They're typically used in preparation for schema changes that might otherwise
# fail, such as for instance adding a unique index.
migration2 = Schema.dataMigration migration1 \db ->
    { id: 1, name: "Roc", tags: ["Fast", "Friendly", "Functional"] }
    |> Query.insert db.langs

# Crow diffs each version of the schema against the previous, to find out what
# modifications to make to the database for a particular migration.
migration1 = Schema.migration Schema.empty \key, {} ->
    langs : Schema.Table { id : U64, name : Str, tags : List Str }
    langs = Schema.table key
    langId = Schema.index key langs .id |> Schema.unique
    langName = Schema.index key langs .name |> Schema.searchable
    { langs, langId, langName }
