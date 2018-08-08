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
        follow:      false
        locked:      false
        position:    [0,0]

    follow: (key, angle) =>
        @set
            angleFollow: angle
            follow: true

    unfollow: =>
        @set
            angleFollow: null
            follow: false

    prepare: =>
        @addDef 'port', new NewPortShape color: @model.color, @

    update: =>
        if @changed.follow
            @updateDef 'port', lockHover: @model.follow
        if @changed.color
            @updateDef 'port', color: @model.color

    adjust: (view) =>
        if @changed.angle or @changed.angleFollow or @changed.locked
            angle = unless @model.locked then @model.angleFollow or @model.angle else @model.angle
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

# import {NewArrow} from 'view/port/sub/NewArrow'
# import {InPort}   from 'view/port/In'

# export class NewPort extends InPort
#     stillPortConstructor: -> NewArrow
