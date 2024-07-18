app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
}

import Schema
import Query

import pf.Task exposing [Task]
import pf.Stdout

main =
    db = Query.connect! "./my-database.radt" latest
    amount =
        db.people
            |> Query.match db.peopleNames (Query.endsWith "Woudenberg")
            |> Query.getCount!
    Stdout.line! "There's $(Num.toStr amount) family in the database!"

# -- schema migrations --

latest = Schema.migration old1 \key, { people, peopleNames } ->
    recipes : Schema.Table { ingredients : List Str }
    recipes = Schema.table key

    {
        people,
        recipes,
        peopleNames,
    }

old1 = Schema.migration Schema.empty \key, {} ->
    people : Schema.Table { name : Str, age : U8 }
    people = Schema.table key

    {
        people,
        peopleNames: Schema.index key people .name |> Schema.searchable,
    }
