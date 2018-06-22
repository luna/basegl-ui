import {SelfPortShape}   from 'shape/port/Self'
import {TextShape}       from 'shape/Text'
import {Subport}         from 'view/port/Port'
import {typeNameXOffset} from 'view/port/sub/Base'

export class Self extends Subport
    initModel: =>
        angle:    0
        hovered:  false
        typeName: ''
        radius:   0
        color:    [0, 1, 0]

    prepare: =>
        @addDef 'port', new SelfPortShape null, @

    update: =>
        @autoUpdateDef 'typeName', TextShape, if @model.hovered
            text: @model.typeName
            align: 'left'

    adjust: (view) =>
        if @model.hovered
            @view('typeName').rotation.z = @model.angle - Math.PI/2
            typeNamePosition = [- typeNameXOffset - @model.radius, 0]
            @view('typeName').position.xy = typeNamePosition

    connectSources: =>
        @__onTypeNameChange()
        @__onRadiusChange()
        @__onColorChange()
        @__onHoverChange()
        @addDisposableListener @parent, 'typeName', => @__onTypeNameChange()
        @addDisposableListener @parent, 'radius', => @__onRadiusChange()
        @addDisposableListener @parent, 'color', => @__onColorChange()
        @addDisposableListener @parent.parent, 'hovered', => @__onHoverChange()

    __onTypeNameChange: =>
        @set typeName: @parent.model.typeName
    __onRadiusChange: =>
        @set radius: @parent.model.radius
    __onColorChange: =>
        @updateDef 'port', color: @parent.model.color
    __onHoverChange: =>
        @set hovered: @parent.parent.model.hovered