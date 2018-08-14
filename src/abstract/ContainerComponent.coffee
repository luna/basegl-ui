import {EventEmitter} from "abstract/EventEmitter"
import {HasModel}     from "abstract/HasModel"

import * as basegl    from 'basegl/display/Symbol'
import * as _         from 'underscore'


export class ContainerComponent extends HasModel
    # __defs: { key -> Component }
    # __view: group
    cons: (args...) =>
        super args...
        @__defs = {}

    dispose: =>
        for own k, def of @__defs
            def.dispose()
        super()

    onModelUpdate: =>
        @update?()
        @adjust? @__view

    view: (key) => @def(key)?.__view

    def: (key) => @__defs[key]

    updateDef: (key, value) =>
        @def(key).set value

    addDef: (key, def) =>
        unless @__defs[key]?
            @__defs[key] = def
            @__addToGroup def.__view
        else unless _.isEqual @__defs[key], def
            @__removeFromGroup @__defs[key]
            @__defs[key].dispose()
            @__addToGroup def.__view
            @__defs[key] = def

    deleteDef: (key) =>
        if @__defs[key]?
            @__removeFromGroup @__defs[key]
            @__defs[key].dispose()
            delete @__defs[key]

    autoUpdateDef: (key, cons, value) =>
        if @def(key)?
            if value?
                @updateDef key, value
            else
                @deleteDef key
        else if value?
            @addDef key, new cons value, @

    deleteDefs: =>
        for own k of @__defs
            @deleteDef k

    # # implement following methods when deriving: #
    # ##############################################
    #
    # initModel: =>
    #     # return model structure (optional, default: {})
    #
    # prepare: =>
    #     # called once, add initial defs here (optional)
    #
    # redefineRequred (values) =>
    #     # test values if it is required to redefine shape (optional, default: false)
    #
    # update: (values) =>
    #     # update defs using @def, @addDef, @deleteDef (optional)
    #
    # registerEvents: (element) =>
    #     # register events on element being group of all defs (optional)
