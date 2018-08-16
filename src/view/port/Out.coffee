import * as shape       from 'shape/port/Base'

import {FlatPortShape}      from 'shape/port/Flat'
import {Port, defaultColor} from 'view/port/Base'
import {OutArrow}           from 'view/port/sub/OutArrow'


export class OutPort extends Port
    initModel: =>
        key:      null
        typeName: ''
        angle:    0
        radius:   0
        color:    defaultColor
        subports: {}

    update: =>
        if (Object.keys @model.subports).length
            if @def 'subport'
                @deleteDef 'subport'
            for own k, subport of @model.subports
                @autoUpdateDef ('sub' + k), OutArrow, angle: subport
        else
            @autoUpdateDef 'subport', OutArrow, angle: @model.angle

    connectionPosition: => @parent.parent.model.position
