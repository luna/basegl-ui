import {Port, defaultColor} from 'view/port/Base'
import {InArrow}            from 'view/port/sub/InArrow'
import {Self}               from 'view/port/sub/Self'


export class InPort extends Port
    initModel: =>
        key:      null
        name:     ''
        typeName: ''
        angle:    0
        subports: {}
        mode:     'in'
        locked:   false
        radius:   0
        color:    defaultColor
        widgets:  []
        position: [0,0]

    portConstructor: => if @model.mode == 'self' then Self else InArrow

    update: =>
        if not @model.locked and (Object.keys @model.subports).length
            if @def 'subport'
                @deleteDef 'subport'
            for own k, subport of @model.subports
                @autoUpdateDef ('sub' + k), @portConstructor(), angle: subport
        else
            @autoUpdateDef 'subport', @portConstructor(), angle: @model.angle

    adjust: (view) =>
        view.position.xy = @model.position

    connectionPosition: =>
        [ @model.position[0] + @parent.parent.model.position[0]
        , @model.position[1] + @parent.parent.model.position[1]
        ]
