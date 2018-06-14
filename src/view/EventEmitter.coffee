import {eventDispatcherMixin}   from 'basegl/event/EventDispatcher'
import {PropertyEmitter}        from "view/PropertyEmitter"

eventListeners = []

export subscribeEvents = (listener) =>
    eventListeners.push listener

export pushEvent = (path, base, key) =>
    unless base.tag? then base.tag = base.constructor.name
    for listener in eventListeners
        listener path, base, key

export class EventEmitter extends PropertyEmitter
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
