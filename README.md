# Crow

A database for Roc. Currently only a design.

## Goals

- Effortless storage and retrieval of any serializable Roc value, like a key-value store.
- Strict schema, indexes, foreign keys, like you have in a relational database.
- Roc is the query language.
- Built on top of SQLite, at least initially.

## Design

- [An example showing what using Crow would look like][example]
- The API is provided by [Schema][schema] andd [Query][query] (just types at this point)

[example]: https://github.com/jwoudenberg/crow/blob/main/main.roc
[schema]: https://github.com/jwoudenberg/crow/blob/main/Schema.roc
[query]: https://github.com/jwoudenberg/crow/blob/main/Query.roc
