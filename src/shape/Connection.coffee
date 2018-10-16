import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'


export width     = 30
overlap = 1


export connectionExpr = (style) -> basegl.expr ->
    eye         = 'scaledEye.z'
    scaledWidth = style.connection_lineWidth * Math.pow(Math.clamp(eye*20.0, 0.0, 400.0),0.85) / 10
    activeArea = rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.activeArea
    connection = rect 'bbox.x', scaledWidth
       .move 'bbox.x'/2, 'bbox.y'/2
       .fill color.varHover style
    activeArea + connection

connectionSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol connectionExpr style
    symbol.defaultZIndex = layers.connection
    symbol.bbox.y = width
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol


export class ConnectionShape extends BasicComponent
    initModel: =>
        offset: 0
        length: 0
        angle: 0
        color: [1,0,0]

    define: => connectionSymbol @style

    adjust: (element, view) =>
        if @changed.length
            element.bbox.x = @model.length + overlap
        if @changed.offset
            element.position.x = @model.offset - overlap/2
        if @changed.once
            element.position.y = - width/2
        if @changed.angle
            element.rotation.z = @model.angle
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]

    registerEvents: (view) =>
        animateHover = (value) =>
            @animateVariable 'hovered', value
        view.addEventListener 'mouseover', => animateHover 1
        view.addEventListener 'mouseout',  => animateHover 0
