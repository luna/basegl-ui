import {eventDispatcherMixin}   from 'basegl/event/EventDispatcher'
import {group}                  from 'basegl/display/Symbol'
import {Composable, fieldMixin} from "basegl/object/Property"

eventListeners = []

export subscribeEvents = (listener) =>
    eventListeners.push listener

export pushEvent = (path, base, key) =>
    unless base.tag? then base.tag = base.constructor.name
    for listener in eventListeners
        listener path, base, key

export class Component extends Composable
    cons: (values, @parent) ->
        @mixin eventDispatcherMixin, @
        @disposables = []
        @propertyListeners = {}
        @set values

    withScene: (fun) => @parent.withScene fun if @parent?

    eventPath: =>
        path = if @parent?
                    @parent.eventPath?() or [@parent.constructor.name]
               else []
        path.push @constructor.name
        path

    pushEvent: (e) => pushEvent @eventPath(), e, @key

    redraw: => @set @

    set: (values) =>
        @updateModel values
        @withScene =>
            if @view?
                @updateView()

    attach: => @withScene (scene) =>
        if @def?
            if @def instanceof Array
                @view = {}
                views = []
                for def in @def
                    @view[def.name] = scene.add def.def
                    views.push @view[def.name]
                @group = group views
            else
                @view = scene.add @def
                @group = group [@view]
            @updateView()
        @registerEvents?()

    _detach: => @withScene (scene) =>
        if @view?
            if @def instanceof Array
                for def in @def
                    @view[def.name].dispose() if @view[def.name]?
            else
                @view.dispose()
            @view = null

    reattach: =>
        @_detach()
        @attach()

    emitProperty: (name, property) =>
        unless @[name] == property
            @[name] = property
            propertyEvent = new CustomEvent name, value: property
            @dispatchEvent propertyEvent if @dispatchEvent?

    dispose: =>
        @disposables.forEach (disposable) =>
            disposable()
        @_detach()

    addDisposableListener: (target, name, handler) =>
        target.addEventListener name, handler
        @onDispose => target.removeEventListener name, handler

    onDispose: (finalizer) =>
        @disposables.push finalizer
