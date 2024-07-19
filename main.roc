app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.12.0/Lb8EgiejTUzbggO2HVVuPJFkwvvsfW6LojkLR20kTVE.tar.br" }

import Schema
import Query

import pf.Task exposing [Task]
import pf.Stdout

# Problems to fix:
#
# - [ ] How to create a table with 1 index?
# - [ ] Joins?
# - [ ] Update tables?

main =
    # When connecting to the database crow checks the version of the database
    # schema, and if necessary runs migrations to bring it to the latest.
    db = Query.connect! "./my-database.crow" latest
    Query.insert! db.langs {
        id: 1,
        name: "Roc",
        tags: ["Fast", "Friendly", "Functional"],
    }

    # We can only query indexes. Any other type of filtering we'll have to do
    # on the data we get back from the database.
    roc =
        db.langs
            |> Query.where .name (Query.equals "Roc")
            |> Query.getOne!

    description = Str.joinWith roc.tags ", "
    Stdout.line! "Roc is all these things: ${description}"

# -- schema migrations --

# Migrations form a chain, each one taking the schema created by the previous
# migration and returning an updated schema. By convention we call the most
# recent migration 'latest'.
latest = Schema.migration migration1 \key, { langs } ->
    people : Schema.Table { id : U64, name : Str, favoriteLang : U64 } _
    people =
        Schema.table
            key
            { Schema.indexes <-
                id: Schema.index .id |> Schema.unique,
                favoriteLang: Schema.index .favoriteLang |> Schema.references langs .id,
            }
    { langs, people }

# Crow diffs each version of the schema against the previous, to find out what
# modifications to make to the database for a particular migration.
migration1 = Schema.migration Schema.empty \key, {} ->
    langs : Schema.Table { id : U64, name : Str, tags : List Str } _
    langs =
        Schema.table
            key
            { Schema.indexes <-
                id: Schema.index .id,
                name: Schema.index .name,
            }

    { langs }
