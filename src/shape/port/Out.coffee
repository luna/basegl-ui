import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {circle, pie}    from 'basegl/display/Shape'
import {nodeRadius}     from 'shape/node/Base'
import * as color       from 'shape/Color'
import {BasicComponent} from 'abstract/BasicComponent'
import * as layers      from 'view/layers'
import {width, length, angle, outArrowRadius, distanceFromCenter, PortShape}  from 'shape/port/Base'

areaAngle = Math.PI / 5
bboxWidth = distanceFromCenter * 1.5
bboxHeight = 2 *  bboxWidth * Math.tan areaAngle

export outPortExpr = basegl.expr ->
    r = outArrowRadius
    c = circle r
       .move bboxWidth/2, 0
    h2 = length - r + r * Math.cos Math.asin ((2*length*Math.tan (angle/2))/r )
    p = pie angle
       .move bboxWidth/2, h2 + r
    port = p - c
    port = port.move 0, - r + length - h2 + distanceFromCenter
        .fill color.varHover()
    activeCutter = circle nodeRadius
        .move bboxWidth/2, 0
    activeArea = pie areaAngle
        .rotate Math.PI
        .move bboxWidth/2, 0
        .fill color.activeArea
    activeArea = activeArea - activeCutter
    activeArea + port

outPortSymbol = basegl.symbol outPortExpr
outPortSymbol.bbox.xy = [bboxWidth,bboxHeight]
outPortSymbol.variables.color_r = 1
outPortSymbol.variables.color_g = 0
outPortSymbol.variables.color_b = 0
outPortSymbol.variables.hovered = 0
outPortSymbol.defaultZIndex = layers.outPort

export class OutPortShape extends PortShape
    define: => outPortSymbol
    adjust: (element) =>
        super element
        element.position.xy = [-bboxWidth/2, -distanceFromCenter]
