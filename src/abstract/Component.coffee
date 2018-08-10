import {group}                  from 'basegl/display/Symbol'
import {EventEmitter}           from "abstract/EventEmitter"


export class Component extends EventEmitter
    cons: (values, @parent) =>
        super()
        @set values
        @attach()

    withScene: (fun) => @parent.withScene fun if @parent?

    redraw: => @set @

    set: (values) =>
        @updateModel values
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

    _detach: =>
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
