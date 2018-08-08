import * as basegl         from 'basegl'
import * as Animation      from 'basegl/animation/Animation'
import * as Easing         from 'basegl/animation/Easing'
import * as Color          from 'basegl/display/Color'
import {circle, pie, rect} from 'basegl/display/Shape'
import {BasicComponent}    from 'abstract/BasicComponent'
import * as color          from 'shape/Color'
import {nodeRadius}        from 'shape/node/Base'
import * as layers         from 'view/layers'
import {width, length, angle, inArrowRadius, distanceFromCenter, PortShape}  from 'shape/port/Base'


areaAngle = Math.PI / 5
bboxWidth = distanceFromCenter * 1.5
bboxHeight = 2 *  bboxWidth * Math.tan areaAngle

export inPortExpr = basegl.expr ->
    r = inArrowRadius
    c = circle r
       .move bboxWidth/2, 0
    p = pie angle
       .rotate Math.PI
       .move bboxWidth/2, distanceFromCenter
    port = c * p
    port = port.fill color.varAlphaHover()
    activeCutter = circle nodeRadius
        .move bboxWidth/2, 0
    activeArea = pie areaAngle
        .rotate Math.PI
        .move bboxWidth/2, 0
        .fill color.activeArea
    activeArea = activeArea - activeCutter
    activeArea + port

inPortSymbol = basegl.symbol inPortExpr
inPortSymbol.bbox.xy = [bboxWidth, bboxHeight]
inPortSymbol.variables.color_r = 1
inPortSymbol.variables.color_g = 0
inPortSymbol.variables.color_b = 0
inPortSymbol.variables.color_a = 1
inPortSymbol.variables.hovered = 0
inPortSymbol.defaultZIndex = layers.inPort

export class InPortShape extends PortShape
    define: => inPortSymbol
    adjust: (element) =>
        super element
        element.position.xy = [-bboxWidth/2, -distanceFromCenter]
