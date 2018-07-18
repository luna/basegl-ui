import {defaultColor}       from 'view/port/Base'
import {ContainerComponent} from 'abstract/ContainerComponent'
import {PhantomPortShape}   from 'shape/port/In'


export class PhantomPort extends ContainerComponent
    initModel: =>
        key:      null
        expanded: false
        radius:   0
        color:    defaultColor
        position: [0,0]

    prepare: =>
        @addDef 'port', new PhantomPortShape color: @model.color, @

    update: =>
        if @changed.color
            @updateDef 'port', color: @model.color

    adjust: (view) =>
        if @changed.expanded
            if @model.expanded
                view.rotation.z = -Math.PI/2
        # if @changed.radius
        #     element.position.x = @model.radius
        if @changed.position
            view.position.xy = @model.position

    connectionPosition: =>
        [ @model.position[0] + @parent.model.position[0]
        , @model.position[1] + @parent.model.position[1]
        ]
