import {SelfPortShape} from 'shape/port/Self'
import {Subport}       from 'view/port/sub/Base'
import * as subport    from 'view/port/sub/Base'
import {TextContainer} from 'view/Text'


export class Self extends Subport
    initModel: =>
        angle:    0
        connected: false
        hovered:  false
        typeName: ''
        radius:   0
        color:    [1, 0, 0]

    prepare: =>
        @addDef 'port', SelfPortShape, null

    update: =>
        @autoUpdateDef 'typeName', TextContainer,
            text: @model.typeName
            align: 'left'
            color: [@style.text_color_r, @style.text_color_g, @style.text_color_b, @model.hovered]
        if @changed.color
            @updateDef 'port', color: @model.color
        if @changed.connected
            @updateDef 'port', connected: @model.connected

    adjust: (view) =>
        if @view('typeName')?
            @view('typeName').rotation.z = @model.angle - Math.PI/2
            typeNamePosition = [- subport.typeNameXOffset(@style) - @model.radius, 0]
            @view('typeName').position.xy = typeNamePosition
