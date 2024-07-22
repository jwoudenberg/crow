module [
    TypeDesc,
    u8,
    str,
    list,
    unit,
    record,
    field,
    tags,
    tag0,
    tag1,
    tag2,
]

TypeDesc a := Desc

Desc : [
    Unit,
    U8,
    Str,
    List Desc,
    Tuple (List Desc),
    Record (List { name : Str, val : Desc }),
    Tags (List { name : Str, params : List Desc }),
]

u8 : TypeDesc U8
u8 = @TypeDesc U8

str : TypeDesc Str
str = @TypeDesc Str

list : TypeDesc a -> TypeDesc (List a)
list = \@TypeDesc elem -> @TypeDesc (List elem)

unit : TypeDesc {}
unit = @TypeDesc Unit

Field a := { name : Str, val : Desc }

record : List (Field record) -> TypeDesc record
record = \fields ->
    List.map fields (\@Field f -> f)
    |> Record
    |> @TypeDesc

# TODO: is it possible use encoders/decoders to enforce field name correctness here?
field : Str, TypeDesc a, (record -> a) -> Field record
field = \name, @TypeDesc val, _ -> @Field { name, val }

Tag a := { name : Str, params : List Desc }

tags : List (Tag a) -> TypeDesc a
tags = \ts ->
    List.map ts (\@Tag f -> f)
    |> Tags
    |> @TypeDesc

# TODO: is it possible use encoders/decoders to enforce tag name correctness here?
tag0 : Str, tag -> Tag tag
tag0 = \name, _ -> @Tag { name, params: [] }

tag1 : Str, TypeDesc a, (a -> tag) -> Tag tag
tag1 = \name, @TypeDesc a, _ -> @Tag { name, params: [a] }

tag2 : Str, TypeDesc a, TypeDesc b, (a, b -> tag) -> Tag tag
tag2 = \name, @TypeDesc a, @TypeDesc b, _ -> @Tag { name, params: [a, b] }
