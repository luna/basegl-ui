import {defaultColor}       from 'view/port/Base'
import {ContainerComponent} from 'abstract/ContainerComponent'
import {PhantomPortShape}   from 'shape/port/In'


export class PhantomPort extends ContainerComponent
    initModel: =>
        key:      null
        color:    defaultColor
        radius:   0
        angle:    0
        position: [0,0]

    prepare: =>
        @addDef 'port', new PhantomPortShape color: @model.color, @

    update: =>
        if @changed.color
            @updateDef 'port', color: @model.color

    adjust: (view) =>
        if @changed.angle
            @view('port').rotation.z = @model.angle
        if @changed.radius
            @view('port').position.y = @model.radius
        if @changed.position
            view.position.xy = @model.position

    connectionPosition: =>
        [ @model.position[0] + @parent.model.position[0]
        , @model.position[1] + @parent.model.position[1]
        ]
