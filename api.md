# API

Feedstock provides its functionality through a single class-level method.

## `Feedstock.feed`

```ruby
Feedstock.feed(url, rules, format = :html, template = "#{__dir__}/../default.xml"
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
  the _info hash_). The keys of the info hash must be symbols, not strings. When
  used with the default template, Feedstock will use the value of the key as the
  value of the XML entity in the resulting feed. For example, if the key is
  `:id`, the XML entity in the resulting feed will be `<id>`.

  The values in the info hash can be:

  - **String**: If the value is a String, this defined a path to a node in the
    document. The path is expressed using CSS's selector syntax. Although a CSS
    selector can match more than one node, when used in the info hash, a path
    will only match the first matching node in the document.

  - **Hash**: If the value is a Hash, this is a _data hash_. A data hash
    defines the rules that Feedstock uses to extract data. It must contain one
    of two keys:

    - `:literal`

      The value associated with this key is used for the content of the XML
      entity. This can be useful for elements that are not on the page or that
      don't change.

    - `:path`

      The path to the node in the document expressed in CSS's selector syntax.
      As noted above, if the value of a key in the info hash is a string, this
      is treated as a path. The reason to use a data hash with a `:path` key is
      when using one or more of the keys below. In the info hash, a path matches
      only the first matching node in the document.

      Feedstock will extract the content in the node pointed to by the path and
      then perform additional transformations if certain keys are provided. For
      a given rule, the order of transformation is: (1) extract; (2) if the
      `:processor` key is set, process; (3) if either or both of the `:prefix`
      and `:suffix` keys is set, wrap; and (4) if the `:type` key is set, format.

      If the `:path` key is specified, the following keys may also be defined
      in the data hash:

      - `:content`

        The default is `nil`. The `:content` key can be set to: (1) `nil`; (2)
        `"inner_html"`; (3) `"html"` or `"xml"`;  or (4) a _hash_ of the form
        `{attribute: "<attribute>"}`. If the value is `"inner_html"`, Feedstock
        will extract the content of the node as HTML. If the value is `"html"`
        or `"xml"`, the HTML (or XML) tag and its contents are converted to a
        String. If the value is an attribute hash, Feedstock will extract the
        value of that attribute.  This is important for links, where the link
        itself is typically the content of the `href` attribute rather than the
        content of the `<a>` element. For all other values, the plaintext
        content of the node is extracted.

      - `:processor`

        The default is `nil`. The `:processor` key can be set to a Lambda that
        takes two arguments. The first is the extracted content, the second is
        the rule being processed. The content extracted by Feedstock for the
        given path is processed by the processor. The Lambda must return a
        String.

      - `:prefix`

        The default is `nil`. If a prefix is provided, the value of the prefix
        is appended to the beginning of the content extracted.

      - `:suffix`

        The default is `nil`. If a suffix is provided, the value of the suffix
        is appended to the end of the content extracted.

      - `:type`

        The default is `nil`. A user may specify `"datetime"` or `"cdata"`. If
        the value is `"datetime"`, the content is parsed by the [Timeliness
        library][Timeliness] to return a string. If the value is `"cdata"`, the
        content is wrapped in `<![CDATA[` and `]]>` tags.

- `:entry`

  The `:entry` key is **mandatory** and must be associated with a Hash (called
  the _entry hash_). The keys of the entry hash must be symbols, not strings.
  When used with the default template, Feedstock will use the key as the name of
  the XML entity in the resulting feed. For example, if the key is `"id"`, the
  XML entity in the resulting feed will be `<id>`.

  The values in the entry hash can be:

  - **String**: If the value is a String, this defines a path to one or more
    nodes in the document. The path is expressed using CSS's selector syntax. If
    an `:entries` key is supplied, the CSS selector will operate like the info
    hash and match only the first node. If an `:entries` key is not supplied,
    the CSS selector will match all nodes matching the path.

  - **Hash**: If the value is a Hash, this is another _data hash_. The data
    hash is the same as that described above in the info hash.

- `:entries`

  The `:entries` key is **optional** and may be associated with a Hash (called
  the _entries hash_). The entries hash allows a user to specify a path to the
  nodes in the document that contain the entries. The keys of the entries hash
  must be symbols, not strings.

  The values in the entries hash can be:

  - **String**: If the value is a String, this defines a path to one or more
    nodes in the document. The path is expressed using CSS's selector syntax.

  - **Hash**: If the value is a Hash, it must contain the following key:

    - `:path`

      The path to the node in the document expressed in CSS's selector syntax.
      This node is used as the root for the paths in the entry hash.

    The following key may also be defined in the entries hash:

    - `:filter`

      The default is `nil`. The `:filter` key can be set to a Lambda that takes
      one argument, a Hash containing the values extracted for the entry. A user
      can then use a Lambda to decide whether to keep or reject the entry. The
      Lambda must return a truthy value to keep the entry.

### `format`

The `format` parameter can be either `:html` or `:xml`. The default is `:html`.

### `template`

The `template` parameter should be a path to an ERB template into which the
information and entries extracted from the document will be inserted. The ERB
template will be passed a Hash containing an `:info` key and an `:entries` key.

A default template is included with Feedstock but a user can also specify their
own template.

[Timeliness]: https://github.com/adzap/timeliness "The official repository for the Timeliness library"
