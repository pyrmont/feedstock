# API

Feedstock provides its functionality through one nested class and two
class-level methods.

## `Feedstock::Extract`

```ruby
Feedstock::Extract.new(selector:, [absolute:, content:, processor:, prefix:, suffix:, type:, filter:])
```

An Extract is a subclass of Struct. Its initialiser takes the following
parameters.

### `selector` _(Required)_

A String representing the path to the node in the document expressed in CSS's
selector syntax.

Feedstock will extract the content in the node pointed to by the path and then
perform additional transformations if certain parameters are provided to the
initialiser. For a given rule, the order of transformation is: (1) extract; (2)
if `processor:` is provided, process; (3) if `prefix:` or `suffix:` is
provided, wrap; and (4) if `type:` is provided, format.

### `absolute` _(Optional)_

A Boolean indicating whether the selector should search from the root of the
document.

### `content` _(Optional)_

A value indicating how to extract the content from the selected node. It can
either be `"inner_html"`, `"html"`, `"xml"` or a Hash of the form `{attribute:
"<attribute>"}`.

If the value is `"inner_html"`, Feedstock will extract the content of the node
as HTML. If the value is `"html"` or `"xml"`, the HTML (or XML) tag and its
contents are converted to a String. If the value is an attribute hash,
Feedstock will extract the value of that attribute. This is important for
links, where the link itself is typically the content of the `href` attribute
rather than the content of the `<a>` element.

If not provided, Feedstock concatenates the text nodes in the selected node's
subtree.

### `processor` _(Optional)_

A Lambda that takes two arguments. The first is the extracted content, the second
is the rule being processed. The Lambda must return a String.

### `prefix` _(Optional)_

A String to prepend to the content extracted.

### `suffix` _(Optional)_

A String to append to the content extracted.

### `type` _(Optional)_

A String representing the type of the content. Valid values are `"datetime"`
and `"cdata"`. If the value is `"datetime"`, the content is parsed by the
[Timeliness library][Timeliness] to return a string. If the value is `"cdata"`,
the content is wrapped in `<![CDATA[` and `]]>` tags.

### `filter` _(Optional)_

A Lambda that takes one argument, a Hash containing the values extracted for
the entry. A user can then use a Lambda to decide whether to keep or reject the
content. The Lambda must return a truthy value to keep the content.

## `Feedstock.data`

```ruby
Feedstock.data(url, rules, format = :html)
```

The `data` method takes up to three parameters and returns a Hash with the keys
`:info` and `:entries`. Each parameter works the same as in `Feedstock.feed`
and is explained in more detail below.

## `Feedstock.feed`

```ruby
Feedstock.feed(url, rules, format = :html, template = "#{__dir__}/../default.xml")
```

The `feed` method takes up to four parameters and returns a String. Each
parameter is explained in more detail below.

### `url`

The `url` parameter is a String and must resolve to either an HTML or XML
document.

### `rules`

The `rules` parameter is a Hash representing a collection of rules. `rules` has
two mandatory keys and one optional key.

- `:info`

  The `:info` key is **mandatory** and must be associated with a Hash (called
  the _info hash_). The keys of the info hash must be symbols, not strings.
  When used with the default template, Feedstock will use the key as the name
  of the XML entity in the resulting document. For example, if the key is
  `:id`, the XML entity in the resulting feed will be `<id>`.

  The values in the info hash can be either a String or an Extract.

- `:entry`

  The `:entry` key is **mandatory** and must be associated with a Hash (called
  the _entry hash_). The keys of the entry hash must be symbols, not strings.
  When used with the default template, Feedstock will use the key as the name of
  the XML entity in the resulting feed. For example, if the key is `"id"`, the
  XML entity in the resulting feed will be `<id>`.

  The values in the entry hash can be either a String or an Extract.

- `:entries`

  The `:entries` key is **optional** and may be associated with an Extract. The
  Extract represents a node within the document to which the selectors in
  the `:entry` rules will be relative.

### `format`

The `format` parameter can be either `:html` or `:xml`. The default is `:html`.

### `template`

The `template` parameter should be a path to an ERB template into which the
information and entries extracted from the document will be inserted. The ERB
template will be passed a Hash containing an `:info` key and an `:entries` key.

A default template is included with Feedstock but a user can also specify their
own template.

[Timeliness]: https://github.com/adzap/timeliness "The official repository for the Timeliness library"
