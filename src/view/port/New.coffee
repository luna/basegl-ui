import {defaultColor}       from 'view/port/Base'
import {ContainerComponent} from 'abstract/ContainerComponent'
import {NewPortShape}       from 'shape/port/New'
import {InArrow}            from 'view/port/sub/InArrow'
import {Subport}            from 'view/port/sub/Base'



export class NewPort extends Subport
    initModel: =>
        key:         null
        color:       defaultColor
        radius:      0
        angle:       0
        angleFollow: null
        locked:      false
        position:    [0,0]

    follow: (key, angle) =>
        @set angleFollow: angle

    unfollow: =>
        @set angleFollow: null

    prepare: =>
        @addDef 'port', NewPortShape, color: @model.color

    update: =>
        if @changed.angleFollow
            @updateDef 'port', lockHover: @model.angleFollow?
        if @changed.color
            @updateDef 'port', color: @model.color

    adjust: (view) =>
        if @changed.angle or @changed.angleFollow or @changed.locked
            angle = if @model.locked then @model.angle else @model.angleFollow or @model.angle
            @view('port').rotation.z = angle
        if @changed.radius
            @view('port').position.y = @model.radius
        if @changed.position
            view.position.xy = @model.position

    connectionPosition: =>
        [ @model.position[0] + @parent.model.position[0]
        , @model.position[1] + @parent.model.position[1]
        ]

    registerEvents: (view) =>
        super view
        view.addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent e
