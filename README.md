# boco-object-source-map

![npm version](https://img.shields.io/npm/v/boco-object-source-map.svg)
![npm license](https://img.shields.io/npm/l/boco-object-source-map.svg)
![dependencies](https://david-dm.org/bocodigitalmedia/boco-object-source-map.png)

Define sources for object properties to support mapping between two object types (ie: Model/Record for DataMapper).

## Installation

Installation is available via [npm] or [github].

```bash
$ npm install boco-object-source-map
$ git clone https://github.com/bocodigitalmedia/boco-object-source-map
```

## Usage

Each property must be mapped to a property source, consisting of one or more resolvers.

* `null` to use the `defaultResolver`
* a string identifying the property to read from the target object
* a function
  * if it is the first resolver, receives `(sourceData, targetPropertyName)`
  * otherwise, receives `(previousResult, targetPropertyName)`

```coffee

ObjectSourceMap = require("boco-object-source-map").ObjectSourceMap

modelSourceMap = new ObjectSourceMap()

# Assign a default resolver to return the value of
# the equivalent database record property
modelSourceMap.defaultResolver = (data, key) ->
  data[require("lodash").snakeCase(key)]

modelSourceMap.define
  id: null
  type: "record_type"
  createdAt: null
  payload: [null, JSON.parse]
  user: (data, key) -> id: record.user_id, type: record.user_type
```

### Resolving

Pass in the data you would like mapped to the `resolve` function to create a new object from the given source.

```coffee

record =
  id: 1
  record_type: "User"
  created_at: new Date()
  payload: '{ "foo": "bar" }'
  user_id: 2
  user_type: "admin"

model = modelSourceMap.resolve record

expect(model.id).toEqual record.id
expect(model.createdAt).toEqual record.created_at
expect(model.payload.foo).toEqual "bar"
expect(model.user.id).toEqual record.user_id
expect(model.user.type).toEqual record.user_type

```

[npm]: https://npmjs.org
[github]: https://github.com

---

The MIT License (MIT)

Copyright (c) 2016 Christian Bradley + Boco Digital Media

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
