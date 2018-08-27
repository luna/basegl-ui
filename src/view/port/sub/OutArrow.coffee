import {OutPortShape}         from 'shape/port/Out'
import {Subport, nameXOffset} from 'view/port/sub/Base'
import {TextContainer}        from 'view/Text'


export class OutArrow extends Subport
    initModel: =>
        angle: 0
        hovered: false
        typeName: ''
        radius: 0

    prepare: =>
        @addDef 'port', OutPortShape, angle: @model.angle

    update: =>
        @autoUpdateDef 'typeName', TextContainer, if @model.hovered
            text: @model.typeName
            align: 'left'

    adjust: (view) =>
        if @changed.radius
            @view('port').position.y = @model.radius
        if @changed.angle
            @view('port').rotation.z = @model.angle
        if @view('typeName')?
            @view('typeName').rotation.z = @model.angle + Math.PI/2
            @view('typeName').position.x = nameXOffset + @model.radius

    registerEvents: (view) =>
        super view
        view.addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent e

    connectSources: =>
        @__onTypeNameChange()
        @__onRadiusChange()
        @__onColorChange()
        @__onHoverChange()
        @addDisposableListener @parent, 'typeName', => @__onTypeNameChange()
        @addDisposableListener @parent, 'radius', => @__onRadiusChange()
        @addDisposableListener @parent, 'color', => @__onColorChange()
        @addDisposableListener @parent.parent.parent, 'hovered', => @__onHoverChange() #TODO: Refactor

    __onTypeNameChange: =>
        @set typeName: @parent.model.typeName
    __onRadiusChange: =>
        @set radius: @parent.model.radius
    __onColorChange: =>
        @updateDef 'port', color: @parent.model.color
    __onHoverChange: =>
        @set hovered: @parent.parent.parent.model.hovered
