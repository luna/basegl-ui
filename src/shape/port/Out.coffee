import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {circle, pie}    from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as layers      from 'view/layers'
import {PortShape}      from 'shape/port/Base'
import * as portBase    from 'shape/port/Base'

areaAngle = Math.PI / 5
bboxWidth =  (style) -> portBase.distanceFromCenter(style) * 1.5
bboxHeight = (style) -> 2 *  bboxWidth(style) * Math.tan areaAngle

export outPortExpr = (style) -> basegl.expr ->
    r = portBase.outArrowRadius style
    c = circle r
       .move bboxWidth(style)/2, 0
    h2 = style.port_length - r + r * Math.cos Math.asin ((2*style.port_length*Math.tan (style.port_angle/2))/r )
    p = pie style.port_angle
       .move bboxWidth(style)/2, h2 + r
    port = (p - c)
        .move 0, - r + style.port_length - h2 + portBase.distanceFromCenter(style)
    background = port.grow style.port_bgSize*(1-'connected')
        .fill color.bg style
    port = port.fill color.varHover style
    activeCutter = circle style.node_radius
        .move bboxWidth(style)/2, 0
    activeArea = pie areaAngle
        .rotate Math.PI
        .move bboxWidth(style)/2, 0
        .fill color.activeArea
    activeArea = activeArea - activeCutter
    activeArea + background + port

outPortSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol outPortExpr style
    symbol.bbox.xy = [bboxWidth(style), bboxHeight(style)]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.hovered = 0
    symbol.variables.connected = 0
    symbol.defaultZIndex = layers.outPort
    symbol

export class OutPortShape extends PortShape
    define: => outPortSymbol @style
    adjust: (element) =>
        super element
        element.position.xy = [-bboxWidth(@style)/2, -portBase.distanceFromCenter(@style) - portBase.offset(@style)]
