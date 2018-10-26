import * as basegl         from 'basegl'
import * as Animation      from 'basegl/animation/Animation'
import * as Easing         from 'basegl/animation/Easing'
import * as Color          from 'basegl/display/Color'
import {circle, pie, rect} from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as color          from 'shape/Color'
import * as layers         from 'view/layers'
import {PortShape}         from 'shape/port/Base'
import * as portBase       from 'shape/port/Base'


activeAreaAngle = Math.PI / 5
bboxWidth = (style) -> portBase.distanceFromCenter(style) * 1.5
bboxHeight = (style) -> 2 *  bboxWidth(style) * Math.tan activeAreaAngle

inPortExpr = (style) -> basegl.expr ->
    r = portBase.inArrowRadius style
    c = circle r
       .move bboxWidth(style)/2, 0
    p = pie style.port_angle
       .rotate Math.PI
       .move bboxWidth(style)/2, portBase.distanceFromCenter(style)
    port = c * p
    background = port.grow style.port_bgSize*(1-'connected')
        .fill color.bg style
    port = port.fill color.varAlphaHover style
    activeCutter = circle style.node_radius
        .move bboxWidth(style)/2, 0
    activeArea = pie activeAreaAngle
        .rotate Math.PI
        .move bboxWidth(style)/2, 0
        .fill color.activeArea
    activeArea = activeArea - activeCutter
    activeArea + background + port

inPortSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol inPortExpr style
    symbol.bbox.xy = [bboxWidth(style), bboxHeight(style)]
    symbol.variables.color_r = 1
    symbol.variables.color_g = 0
    symbol.variables.color_b = 0
    symbol.variables.color_a = 1
    symbol.variables.hovered = 0
    symbol.variables.connected = 0
    symbol.defaultZIndex = layers.inPort
    symbol

export class InPortShape extends PortShape
    define: => inPortSymbol @style
    adjust: (element) =>
        super element
        element.position.xy = [-bboxWidth(@style)/2, -portBase.distanceFromCenter(@style) - portBase.offset(@style)]
