# Crow

A database for Roc. Currently only a design.

## Goals

- Effortless storage and retrieval of any serializable Roc value, like a key-value store.
- Strict schema, indexes, foreign keys, like you have in a relational database.
- Roc is the query language.
- Built on top of SQLite, at least initially.

## Design

- [An example showing what using Crow would look like][example]
- The API is provided by two modules [Schema][schema] and [Query][query] (just types at this point)

## Motivation for design choices

### Data normalization

Crow tables will only store values of a particular type, but that type can contain any amount of nested structure. The upside of this is that we don't need to change the representation of the data when we store it in the database, similar to document stores. But allowing arbitrarily nested data also means we don't enforce some measure of data normalization.

I think it's fine not to encourage data normalization too strongly. Looking back I think I've more often run into issues because data was normalized too much rather than not enough. For early projects where we're still figuring out the best structure of the data, I find normalization to be a big overhead. For large projects I've ran into performance problems when loading a particular object required querying different tables. Also, I've found storing ADTs in relational databases tricky.

More important to me is having assurances on the shape of data stored, and having tools for comfortably/safely modifying that shape.

### Sqlite

I'd like to build a first version on top of sqlite, because [roc-pg][] exists and is great for scenarios where you want a database server, and it'd be nice to have a 'type-safe' database in domains where sqlite is a good fit. I'm thinking mobile app development and local applications.

Using Sqlite puts some limits on the design of the API. For instance, suppose we want to store a tree structure in a table with each leaf a foreign key to some other table. Such a use would fit the design goals of Crow well, but it would result in an arbitrary amount of foreign keys per row, and so I don't think it's possible to model in SQL directly.

I imagine that for each type in the Crow schema, we create a table in Sqlite. The value itself is binary-encoded and saved as a blob. For each index defined in the schema we add a column. Potentially index types should encoded as native sqlite type when possible, for compatibility with WHERE comparisons.

### Query language (or absence thereof)

One aspect I'm not a fan of in programming against relational databases is that there's typically two layers to it. There's the SQL that the database understands, and then typically some library abstraction on top. In theory the nicer library abstraction should save you from having to know SQL, but in practice I've needed both in any project with a relation database I worked with. That the SQL typically only comes in to play for hard problems creates a weird learning curve too.

So for Crow I'd like to avoid SQL, or any dedicated query language, and make the Roc query API the default and only human interface to the database.

I think if the Roc repl gains the ability to run effects in the future, that would make it great for interactive use of the database.

### Schema and Migrations

I've really enjoyed working with tools that generate types from a database schema and use this to type-check app queries, in Haskell and Android development. In this approach the database has a schema, the generated code describes a schema, and the hand-written code assumes a schema. Hopefully these are all the same schema, but I've definitely ended up in situations where they were not.

I think Crow can avoid most of this by describing the database schema and migrations in the app codebase itself, and automatically migrating a database forward to the app version when connecting to it. Without a code-generation component, the app author can change code or change the schema, and use `roc check` and `roc test` to test the changes like normal.

Furthermore, if the app author is okay with the risk of some data loss in development, then Crow can automatically keep a development database up-to-date with the latest schema. To do this it would create a snapshots of each version of the schema. Upon noticing a schema change, it would find the most recent schema version for which a snapshot exists, then roll migrations forwards from there. Because Crow will migrate upon connection, this should integrate seamlessly with future watch mode support.

The process of writing schemas would be much nicer if Roc offers some way to perform runtime type introspection. Crow would use this to get a 'hash' of each table-type and use it to detect changes to the schema made by migrations. My backup plan (not in the current design) is to require users to describe the types using a value-level DSL, but it'd be a shame to have to teach users a language for describing Roc types if they already know one.

[example]: https://github.com/jwoudenberg/crow/blob/main/main.roc
[schema]: https://github.com/jwoudenberg/crow/blob/main/Schema.roc
[query]: https://github.com/jwoudenberg/crow/blob/main/Query.roc
[roc-pg]: https://github.com/agu-z/roc-pg
