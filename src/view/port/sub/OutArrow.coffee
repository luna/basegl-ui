import {OutPortShape}  from 'shape/port/Out'
import {Subport}       from 'view/port/sub/Base'
import * as subport    from 'view/port/sub/Base'
import {TextContainer} from 'view/Text'


export class OutArrow extends Subport
    initModel: =>
        angle: 0
        connected: false
        color: [1, 0, 0]
        hovered: false
        typeName: ''
        radius: 0

    prepare: =>
        @addDef 'port', OutPortShape, angle: @model.angle

    update: =>
        @autoUpdateDef 'typeName', TextContainer, if @model.typeName
            text: @model.typeName
            align: 'left'
            color: [@model.color[0], @model.color[1], @model.color[2], @model.hovered]
            frameColor:
                [ @style.port_borderColor_h, @style.port_borderColor_s
                , @style.port_borderColor_l, @style.port_borderColor_a * Number @model.hovered
                ]
        if @changed.connected
            @updateDef 'port', connected: @model.connected
        if @changed.color
            @updateDef 'port', color: @model.color

    adjust: (view) =>
        if @changed.radius
            @view('port').position.y = @model.radius
        if @changed.angle
            @view('port').rotation.z = @model.angle
        if @view('typeName')?
            @view('typeName').rotation.z = @model.angle + Math.PI/2
            @view('typeName').position.x = subport.nameXOffset(@style) + @model.radius

    registerEvents: (view) =>
        super view
        view.addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent e
