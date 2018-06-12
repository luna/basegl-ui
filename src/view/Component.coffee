import {eventDispatcherMixin}   from 'basegl/event/EventDispatcher'
import {group}                  from 'basegl/display/Symbol'
import {fieldMixin}             from "basegl/object/Property"
import {Disposable}             from "view/Disposable"
import {PropertyEmitter}        from "view/PropertyEmitter"

eventListeners = []

export subscribeEvents = (listener) =>
    eventListeners.push listener

export pushEvent = (path, base, key) =>
    unless base.tag? then base.tag = base.constructor.name
    for listener in eventListeners
        listener path, base, key

export class Component extends PropertyEmitter
    cons: (values, @parent) =>
        super()
        @set values

    withScene: (fun) => @parent.withScene fun if @parent?

    eventPath: =>
        path = if @parent?
                    @parent.eventPath?() or [@parent.constructor.name]
               else []
        path.push @constructor.name
        path

    eventKey: =>
        key = @parent?.eventKey?() or []
        key.push @key if @key?
        key

    pushEvent: (e) => pushEvent @eventPath(), e, @eventKey()

    redraw: => @set @

    set: (values) =>
        @updateModel values
        @withScene =>
            if @view?
                @updateView()

    attach: => @withScene (scene) =>
        if @def?
            if @def instanceof Array
                @element = {}
                @view = {}
                views  = []
                for def in @def
                    @element[def.name] = scene.add def.def
                    @view[def.name] = group [@element[def.name]]
                    views.push @view[def.name]
                @group = group views
            else
                @element = scene.add @def
                @view  = @element
                @group = group [@view]
            @updateView()
        @registerEvents?()

    _detach: => @withScene (scene) =>
        if @view?
            if @view.dispose?
                @view.dispose()
            else for own k,v of @view
                v.dispose()
            @view  = null
            @group = null

    reattach: =>
        @_detach()
        @attach()

    destruct: => @_detach()
