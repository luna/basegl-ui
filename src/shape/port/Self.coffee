import * as basegl         from 'basegl'
import * as Color          from 'basegl/display/Color'
import {circle, rect}            from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol}    from 'abstract/BasicComponent'
import * as color          from 'shape/Color'
import {length, PortShape} from 'shape/port/Base'
import * as layers         from 'view/layers'


radius = (style) -> style.port_selfRadius

export selfPortExpr = (style) -> basegl.expr ->
    c = circle radius(style)
       .move radius(style), radius(style)
       .fill color.transparent

selfPortSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol selfPortExpr style
    symbol.bbox.xy = [2 * radius(style), 2 * radius(style)]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol.variables.connected = 0
    symbol.defaultZIndex = layers.selfPort
    symbol

export class SelfPortShape extends PortShape
    define: => selfPortSymbol @style
    adjust: (element) =>
        super element
        element.position.xy = [-radius(@style), -radius(@style)]
