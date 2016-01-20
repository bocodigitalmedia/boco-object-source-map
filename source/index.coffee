configure = ->

  class ObjectSourceMapError extends Error
    @code: "ER_OBJECT_SOURCE_MAP_ERROR"

    constructor: (message, payload) ->
      @name = @constructor.name
      @code = @constructor.code
      @message = message
      @payload = payload
      Error.captureStackTrace @, @constructor

  class InvalidPropertySourceResolver extends ObjectSourceMapError
    @code: "ER_INVALID_PROPERTY_SOURCE_RESOLVER"

    constructor: (message, {resolver}) ->
      message ?= "Invalid PropertySourceResolver: #{JSON.stringify(resolver)}"
      super message, {resolver}

  class PropertySourceNotFound extends ObjectSourceMapError
    @code: "ER_PROPERTY_SOURCE_NOT_FOUND"

    constructor: (message, {property}) ->
      message ?= "Source not found for '#{property}'"
      super message, {property}

  class PropertySource
    property: null
    resolvers: null

    constructor: (props) ->
      @[key] = val for own key, val of props
      @resolvers ?= []

    applyResolver: (data, resolver) ->
      resolver data, @property

    resolve: (data) ->
      @resolvers.reduce @applyResolver.bind(@), data

  class ObjectSourceMap
    propertySources: null
    defaultResolver: null

    constructor: (props) ->
      @[key] = val for own key, val of props when key isnt 'propertySources'
      @propertySources ?= {}
      @definePropertySources props?.propertySources if props?.propertySources

    createResolver: (resolver) ->
      resolver ?= @defaultResolver
      return resolver if typeof resolver is 'function'
      return ((data) -> data[resolver]) if typeof resolver is 'string'
      throw new InvalidPropertySourceResolver null, {resolver}

    createPropertySource: (property, resolvers) ->
      resolvers = [].concat(resolvers).map @createResolver.bind(@)
      new PropertySource {property, resolvers}

    definePropertySource: (property, resolvers) ->
      @propertySources[property] = @createPropertySource(property, resolvers)

    definePropertySources: (propertyResolvers) ->
      @definePropertySource property, resolvers for own property, resolvers of propertyResolvers

    definePropertiesSource: (properties, resolvers) ->
      @definePropertySource property, resolvers for property in properties

    getPropertySource: (property) ->
      return @propertySources[property] if @propertySources.hasOwnProperty(property)
      throw new PropertySourceNotFound null, {property}

    resolvePropertySource: (data, property) ->
      @getPropertySource(property).resolve data

    resolvePropertySources: (data, properties) ->
      resolved = {}
      resolved[property] = @resolvePropertySource(data, property) for property in properties
      resolved

    resolve: (data) ->
      properties = Object.getOwnPropertyNames @propertySources
      @resolvePropertySources data, properties

    define: (propertySources) ->
      @definePropertySources propertySources

  Errors = {ObjectSourceMapError, InvalidPropertySourceResolver, PropertySourceNotFound}
  BocoObjectSourceMap = {configure, ObjectSourceMap, PropertySource, Errors}

module.exports = configure()
