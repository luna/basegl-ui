import {eventDispatcherMixin}   from 'basegl/event/EventDispatcher'
import {PropertyEmitter}        from "abstract/PropertyEmitter"

eventListeners = []

export subscribeEvents = (listener) =>
    eventListeners.push listener


export class EventEmitter extends PropertyEmitter
    eventPath: =>
        path = if @parent?
                    @parent.eventPath?() or [@parent.constructor.name]
               else []
        path.push @constructor.name
        path

    eventKey: =>
        key = @parent?.eventKey?() or []
        if @model?.key? and (not (@model.key in key))
            key.push @model.key
        key

    pushEvent: (e) =>
        __performPushEvent @eventPath(), e, @eventKey()

    __performPushEvent = (path, base, key) =>
        unless base.tag? then base.tag = base.constructor.name
        for listener in eventListeners
            listener path, base, key
