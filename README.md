# RADT

A RAD database. Design goals:

- Effortless storage and retrieval of Roc values.
- Can store nested data, like a document store. Has strict schema, indexes, and foreign keys, like a relation database.
- Using sqlite for database internals, for use in many domains (Android, local applications, simple servers). Though other backends can be considered in the future.
- Never add a query language. Roc is the query language, and for interactive use we have the REPL.
