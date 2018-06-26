import * as basegl                  from 'basegl'
import * as Color                   from 'basegl/display/Color'
import {circle, pie}                from 'basegl/display/Shape'
import {nodeSelectionBorderMaxSize} from 'shape/node/Base'
import * as color                   from 'shape/Color'
import {BasicComponent}             from 'abstract/BasicComponent'
import * as layers                  from 'view/layers'
import {width, length, angle, outArrowRadius, distanceFromCenter}  from 'shape/port/Base'

areaAngle = Math.PI / 5
bboxWidth = distanceFromCenter * 2
bboxHeight = 2 *  bboxWidth * Math.tan areaAngle

export outPortExpr = basegl.expr ->
    r = outArrowRadius
    c = circle r
       .move bboxHeight/2-width, 0
    h2 = length - r + r * Math.cos Math.asin ((2*length*Math.tan (angle/2))/r )
    p = pie angle
       .move bboxHeight/2-width, h2 + r
    port = p - c
    port = port.move 0, - r + length - h2 + distanceFromCenter
        .fill Color.rgb ['color_r', 'color_g', 'color_b']
    activeArea = pie areaAngle
        .rotate Math.PI
        .move bboxWidth/2, 0
        .fill color.activeArea
    activeArea + port

outPortSymbol = basegl.symbol outPortExpr
outPortSymbol.bbox.xy = [bboxWidth,bboxHeight]
outPortSymbol.variables.color_r = 1
outPortSymbol.variables.color_g = 0
outPortSymbol.variables.color_b = 0
outPortSymbol.defaultZIndex = layers.outPort

export class OutPortShape extends BasicComponent
    initModel: => color: [1,0,0]
    define: => outPortSymbol
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]
        element.position.xy = [-bboxWidth/2, length - bboxHeight/2]
