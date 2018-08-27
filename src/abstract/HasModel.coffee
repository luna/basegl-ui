import {EventEmitter} from "abstract/EventEmitter"
import * as basegl    from 'basegl/display/Symbol'
import * as _         from 'underscore'
import {mat4}         from 'gl-matrix'


unArray = (ref, obj) =>
    if ref? and (not Array.isArray ref) and Array.isArray obj
        ret = {}
        for el in obj
            ret[el.key] = el
        ret
    else
        obj

export class HasModel extends EventEmitter
    cons: (values, @parent) =>
        super()
        @root =  @parent?.root or @parent or @

    init: (values) =>
        super()
        @__view = basegl.group []
        @model = @initModel?() or {}
        @changed = {}
        @__setValues values, true
        @changed.once = true
        @prepare?()
        @onModelUpdate values
        @connectSources?()
        @registerEvents? @__view
        @changed.once = false

    withScene: (fun) => @parent?.withScene fun

    set: (values) =>
        return if @disposed
        @__setValues values
        if @__anythingChanged
            @onModelUpdate values
            @performEmit 'modelUpdated', values

    __setValues: (values, once = false) =>
        values ?= {}
        @__anythingChanged = once
        for own key of @model
            @changed[key] = once
            value = unArray @model[key], values[key]
            if value != undefined and not _.isEqual @model[key], value
                @changed[key] = true
                @__anythingChanged = true
                @model[key] = value
                @performEmit key, value

    __addToGroup: (view) =>
        @__view.addChild view
        @__view.updateChildrenOrigin()

    __removeFromGroup: (view) =>
        @__view.removeChild view
        @__view.updateChildrenOrigin()
        view.setOrigin mat4.create()

    log:  (msg) => console.log  "[#{@constructor.name}]", msg
    warn: (msg) => console.warn "[#{@constructor.name}]", msg
