import {Port, defaultColor} from 'view/port/Base'
import {OutArrow}           from 'view/port/sub/OutArrow'


export class OutPort extends Port
    initModel: =>
        angle:    0
        color:    defaultColor
        hovered:  false
        key:      null
        typeName: ''
        radius:   0
        subports: {}

    portConstructor: => OutArrow

    update: =>
        if (Object.keys @model.subports).length
            if @def 'subport'
                @deleteDef 'subport'
            @updateDef 'subports',
                elems: for own k, subport of @model.subports
                    angle:     subport
                    connected: true
                    color:     @model.color
                    hovered:   @model.hovered
                    key:       k
                    radius:    @model.radius
                    typeName:  @model.typeName
        else
            @updateDef 'subports', elems: []
            @autoUpdateDef 'subport', OutArrow,
                angle:     @model.angle
                connected: (Object.keys @model.subports).length > 0
                color:     @model.color
                hovered:   @model.hovered
                radius:    @model.radius
                typeName:  @model.typeName

    connectionPosition: => @parent.parent.model.position

    connectSources: =>
        @__onHoverChange()
        @addDisposableListener @parent.parent, 'hovered', => @__onHoverChange() #TODO: Refactor

    __onHoverChange: (e) =>
        @set hovered: @parent.parent.model.hovered
