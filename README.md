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

The `"info"` key is mandatory. It must be associated with a hash. This document
refers to this hash as the 'info hash'.

#### Keys

The keys in the info hash are strings (not symbols). When used with the default
template, Feedstock will use the key as the name of the XML entity in the
resulting feed. For example, if the key is `"id"`, the XML entity in the
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

If the value is a hash, this is the 'data hash'. The data hash defines the
rules that Feedstock uses to extract data. It must contain one of two keys:

- `"literal"`: The value associated with this key is used for the content of the
  XML entity. This can be useful for elements that are not on the page or that
  don't change.

- `"path"`: The path to the node in the document expressed in CSS's selector
  syntax.  As noted above, if the value of a key in the info hash is a string,
  this is treated as a path. The reason to use a data hash with a `"path"` key
  is when using one or more of the keys below. In the info hash, a path matches
  only the first matching node in the document.

The following keys may also be defined in a data hash:

- `"attribute"`: The default is `nil`. If an attribute is provided, Feedstock
  will extract the content of the attribute rather than the content of the node.
  This is important for links, where the link itself is typically the content of
  the `href` attribute rather than the content of the `<a>` element.

- `"prefix"`: The default is `nil`. If a prefix is provided, the string value of
  the prefix is appended to the beginning of the content extracted.

- `"suffix"`: The default is `nil`. If a suffix is provided, the string value of
  the suffix is appended to the end of the content extracted.

- `"type"`: The default is `nil`. This causes Feedstock to extract only the text
  in a node (stripping out all HTML). However, a user may specify `"datetime"`
  or `"cdata"`. `"datetime"` content is parsed by [the Timeliness
  library][Timeliness] (this is bundled with Feedstock) to return a string.
  `"cdata"` content includes any HTML and is wrapped in `<![CDATA[` and `]]>`
  tags.

[Timeliness]: https://github.com/adzap/timeliness "The official repository for
the Timeliness library"

### Entry

The `"entry"` key is mandatory. It must be associated with a hash. This document
refers to this hash as the 'entry hash'.

#### Keys

The keys in the entry hash are strings (not symbols). When used with the default
template, Feedstock will use the key as the name of the XML entity in the
resulting feed. For example, if the key is `"id"`, the XML entity in the
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

- `"literal"`: The value associated with this key is used for the content of the
  XML entity. This can be useful for elements that are not on the page or that
  don't change.

- `"path"`: The path to the node in the document expressed in CSS's selector
  syntax. Unlike with the info hash, the CSS selector will match all nodes. 

The following keys may also be defined in a data hash:

- `"attribute"`: The default is `nil`. If an attribute is provided, Feedstock
  will extract the content of the attribute rather than the content of the node.
  This is important for links, where the link itself is typically the content of
  the `href` attribute rather than the content of the `<a>` element.

- `"infix"`: The default is `nil`. If the entries hash has been provided (see
  below), then the string value of the infix is inserted between the content of
  each matching node. If the entries hash not been provided, this is ignored.

- `"prefix"`: The default is `nil`. If a prefix is provided, the string value of
  the prefix is appended to the beginning of the content extracted.

- `"repeat"`: The default is `nil`. If repeat is set to `true`, Feedstock will
  use the content provided by either `"literal"` or `"path"` repeatedly. Since
  the value of `"literal"` implies `"repeat"`, it is not necessary to specify it
  expressly.

- `"suffix"`: The default is `nil`. If a suffix is provided, the string value of
  the suffix is appended to the end of the content extracted.

- `"type"`: The default is `nil`. This causes Feedstock to extract only the text
  in a node (stripping out all HTML). However, a user may specify `"datetime"`
  or `"cdata"`. `"datetime"` content is parsed by [the Timeliness
  library][Timeliness] (this is bundled with Feedstock) to return a string.
  `"cdata"` content includes any HTML and is wrapped in `<![CDATA[` and `]]>`
  tags.

### Entries

The `"entries"` key is optional. It can be associated with a hash. This document
refers to this hash as the 'entries hash'.

If an entries hash is provided, it must contain the following key:

- `"path"`: The path to the node in the document expressed in CSS's selector
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
