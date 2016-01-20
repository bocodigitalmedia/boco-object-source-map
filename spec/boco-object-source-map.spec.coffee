$files = {}

describe "boco-object-source-map", ->

  describe "Usage", ->
    [ObjectSourceMap, modelSourceMap, data, key, record] = []

    beforeEach ->
      
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

    describe "Resolving", ->

      it "Pass in the data you would like mapped to the `resolve` function to create a new object from the given source.", ->
        
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
