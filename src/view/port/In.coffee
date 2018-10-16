import {Port, defaultColor} from 'view/port/Base'
import {InArrow}            from 'view/port/sub/InArrow'
import {Self}               from 'view/port/sub/Self'


export class InPort extends Port
    initModel: =>
        angle:    0
        color:    defaultColor
        hovered:  false
        key:      null
        expanded: false
        mode:     'in'
        name:     ''
        position: [0,0]
        radius:   0
        subports: {}
        typeName: ''
        widgets:  []

    portConstructor: => if @model.mode == 'self' then Self else InArrow

    update: =>
        if (Object.keys @model.subports).length
            if @def 'subport'
                @deleteDef 'subport'
            @updateDef 'subports',
                elems: for own k, subport of @model.subports
                    angle:     subport
                    color:     @model.color
                    connected: true
                    hovered:   @model.hovered
                    key:       k
                    name:      @model.name
                    radius:    @model.radius
                    typeName:  @model.typeName
                    locked:    @model.locked
        else
            @updateDef 'subports', elems: []
            @autoUpdateDef 'subport', @portConstructor(),
                angle: @model.angle
                color: @model.color
                connected: (Object.keys @model.subports).length > 0
                hovered: @model.hovered
                name: @model.name
                radius: @model.radius
                typeName: @model.typeName

    adjust: (view) =>
        @setPosition view, @model.position

    connectionPosition: =>
        [ @model.position[0] + @parent.parent.model.position[0]
        , @model.position[1] + @parent.parent.model.position[1]
        ]

    connectSources: =>
        @__onHoverChange()
        @addDisposableListener @parent.parent, 'hovered', => @__onHoverChange() #TODO: Refactor

    __onHoverChange: (e) =>
        @set hovered: @parent.parent.model.hovered
