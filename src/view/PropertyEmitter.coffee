import {eventDispatcherMixin}   from 'basegl/event/EventDispatcher'
import {Disposable}             from "view/Disposable"

export class PropertyEmitter extends Disposable
    cons: ->
        super()
        @mixin eventDispatcherMixin, @

    emitProperty: (name, property) =>
        unless @[name] == property
            @[name] = property
            propertyEvent = new CustomEvent name, value: property
            @dispatchEvent propertyEvent if @dispatchEvent?
