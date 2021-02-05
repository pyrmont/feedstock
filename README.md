# Feedstock

Feedstock is a Ruby library for extracting information from a webpage and
converting it into an Atom feed.

## Rationale

Feeds are great. But sometimes a website doesn't provide a feed or doesn't
provide a feed for the specific content that you want. That's where Feedstock
can help.

Feedstock is a Ruby library that you can use to create an Atom feed. It takes a
URL to the webpage to check and a hash of rules. The rules tell Feedstock how to
extract and transform the data it finds on the webpage.

## Example

The [feeds.inqk.net repository][example] includes an example of how the Feedstock
library can be used in practice.

[example]: https://github.com/pyrmont/feeds.inqk.net/tree/4a95a438f8d3a707db7946238181ab76c029ee77/src/input
"An example of using the Feedstock library"

## Installation

Feedstock is available as a gem:

```shell
$ gem install feedstock
```

## Usage

Feedstock extracts information from a given document using a collection of
_rules_.

A collection of rules is expressed as a hash. The hash has two mandatory keys
and one optional key.

### Info

The `:info` key is mandatory. It must be associated with a hash. In this
README, this hash is referred to as the _info hash_.

#### Keys

The keys in the info hash should be symbols, not strings. When used with the
default template, Feedstock will use the key as the name of the XML entity in
the resulting feed. For example, if the key is `:id`, the XML entity in the
resulting feed will be `<id>`.

#### Values

The value associated with each key in the info hash can be either a string or a
hash.

##### String

If the value is a string, this defines a path to a node in the document. The
path is expressed using CSS's selector syntax. Although a CSS selector can match
more than one node, when used in the info hash, a path will only match the first
matching node in the document.

##### Hash

If the value is a hash, this is the _data hash_. The data hash defines the
rules that Feedstock uses to extract data. It must contain one of two keys:

- `:literal`: The value associated with this key is used for the content of the
  XML entity. This can be useful for elements that are not on the page or that
  don't change.

- `:path`: The path to the node in the document expressed in CSS's selector
  syntax.  As noted above, if the value of a key in the info hash is a string,
  this is treated as a path. The reason to use a data hash with a `:path` key
  is when using one or more of the keys below. In the info hash, a path matches
  only the first matching node in the document.

The following keys may also be defined in a data hash:

- `:content`: The default is `nil`. The `:content` key can be set to
  `"inner_html"` or a _hash_ of the form `{attribute: "<attribute>"}`. If the
  value is `"inner_html"`, Feedstock will extract the content of the node as
  HTML. If the value is an attribute hash, Feedstock will extract the value of
  that attribute. This is important for links, where the link itself is
  typically the content of the `href` attribute rather than the content of the
  `<a>` element. For all other values, the plaintext content of the node is
  extracted.

- `:processor`: The default is `nil`. The `:processor` key can be set to a
  lambda function that takes two arguments. The first is the extracted content,
  the second is the rule being processed. The content extracted by Feedstock for
  the given path is processed by the processor.

- `:prefix`: The default is `nil`. If a prefix is provided, the string value of
  the prefix is appended to the beginning of the content extracted.

- `:suffix`: The default is `nil`. If a suffix is provided, the string value of
  the suffix is appended to the end of the content extracted.

- `:type`: The default is `nil`. A user may specify `"datetime"` or `"cdata"`.
  If the value is `"datetime"`, the content is parsed by the [Timeliness
  library][Timeliness] to return a string. If the value is `"cdata"`, the
  content is wrapped in `<![CDATA[` and `]]>` tags.

[Timeliness]: https://github.com/adzap/timeliness "The official repository for
the Timeliness library"

#### Formatting Order

The order for formatting content is: extract, process, wrapping.

### Entry

The `:entry` key is mandatory. It must be associated with a hash. In this
README, this hash is referred to as the _entry hash_.

#### Keys

The keys in the entry hash should be symbols, not strings. When used with the
default template, Feedstock will use the key as the name of the XML entity in
the resulting feed. For example, if the key is `"id"`, the XML entity in the
resulting feed will be `<id>`.

#### Values

The value associated with each key in the entry hash can be either a string or a
hash.

##### String

If the value is a string, this defines a path to a node in the document. The
path is expressed using CSS's selector syntax. Unlike with the info hash, a
the CSS selector will match all nodes.

##### Hash

If the value is a hash, we call this the "data hash". The data hash defines the
rules that Feedstock uses to extract data. It must contain one of two keys:

- `:literal`: The value associated with this key is used for the content of the
  XML entity. This can be useful for elements that are not on the page or that
  don't change.

- `:path`: The path to the node in the document expressed in CSS's selector
  syntax. Unlike with the info hash, the CSS selector will match all nodes.

The following keys may also be defined in a data hash:

- `:content`: The default is `nil`. The `:content` key can be set to
  `"inner_html"` or a _hash_ of the form `{attribute: "<attribute>"}`. If the
  value is `"inner_html"`, Feedstock will extract the content of the node as
  HTML. If the value is an attribute hash, Feedstock will extract the value of
  that attribute. This is important for links, where the link itself is
  typically the content of the `href` attribute rather than the content of the
  `<a>` element. For all other values, the plaintext content of the node is
  extracted.

- `:repeat`: The default is `nil`. If repeat is set to `true`, Feedstock will
  use the content provided by either `:literal` or `:path` repeatedly. Since
  the value of `:literal` implies `:repeat`, it is not necessary to specify it
  expressly.

- `:processor`: The default is `nil`. The `:processor` key can be set to a
  lambda function that takes two arguments. The first is the extracted content,
  the second is the rule being processed. The content extracted by Feedstock for
  the given path is processed by the processor.

- `:prefix`: The default is `nil`. If a prefix is provided, the string value of
  the prefix is appended to the beginning of the content extracted.

- `:suffix`: The default is `nil`. If a suffix is provided, the string value of
  the suffix is appended to the end of the content extracted.

- `:type`: The default is `nil`. A user may specify `"datetime"` or `"cdata"`.
  If the value is `"datetime"`, the content is parsed by the [Timeliness
  library][Timeliness] to return a string. If the value is `"cdata"`, the
  content is wrapped in `<![CDATA[` and `]]>` tags.

### Entries

The `:entries` key is optional. It can be associated with a hash. In this
README, this hash is referred to as the _entries hash_.

The entries hash is offered as a convenience. It allows a user to simplify
the paths used in the entry hash by omitting a reference to the node
containing the entries.

If an entries hash is provided, it must contain the following key:

- `:path`: The path to the node in the document expressed in CSS's selector
  syntax. This path is used as the root for the paths in the entry hash.

## Bugs

Found a bug? I'd love to know about it. The best way is to report them in the
[Issues section][ghi] on GitHub.

[ghi]: https://github.com/pyrmont/feedstock/issues

## Versioning

Feedstock uses [Semantic Versioning 2.0.0][sv2].

[sv2]: http://semver.org/

## Licence

Feedstock is released into the public domain. See [LICENSE.md][lc] for more
details.

[lc]: https://github.com/pyrmont/feedstock/blob/master/LICENSE.md
