import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Animation   from 'basegl/animation/Animation'
import * as Color       from 'basegl/display/Color'
import {pie, rect}      from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'
import {PortShape}      from 'shape/port/Base'

width     = (style) -> style.port_length * Math.tan style.port_angle
bboxHeight = (style) -> width(style) * 2
bboxWidth = (style) -> style.port_length*5
overlap = 1

export flatPortExpr = (style) -> basegl.expr ->
    activeArea = rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.activeArea
    cutterWidth = 'bbox.x' - style.port_length
    cutter = rect cutterWidth + overlap, 'bbox.y' + overlap
        .move (1-'is_output')*style.port_length + cutterWidth/2, 'bbox.y'/2
        # .fill color.activeArea
    port = pie -style.port_angle
        .rotate -Math.PI /2
        .move (bboxWidth(style)*'is_output' + style.port_length*(1-'is_output')), bboxHeight(style)/2
    port = port - cutter
    port = port.fill color.varHover style
    activeArea + port

flatPortSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol flatPortExpr style
    symbol.bbox.xy = [bboxWidth(style), bboxHeight(style)]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol.variables.connected = 0
    symbol.variables.is_output = 0
    symbol.defaultZIndex = layers.flatPort
    symbol

export class FlatPortShape extends PortShape
    initModel: =>
        model = super()
        model.output = null
        model
    define: => flatPortSymbol @style
    adjust: (element) =>
        super element
        if @changed.output
            x = if @model.output then (- bboxWidth(@style)) else 0
            element.variables.is_output = Number @model.output
            element.position.xy = [x, -bboxHeight(@style)/2]
