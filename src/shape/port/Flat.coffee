import {BasicComponent} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Animation   from 'basegl/animation/Animation'
import * as Color       from 'basegl/display/Color'
import {pie, rect}      from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'

angle = Math.PI/3
export length    = 10
export width     = length * Math.tan angle

bboxHeight = width*2
bboxWidth = length*5

export flatPortExpr = basegl.expr ->
    activeArea = rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.activeArea
    cutterWidth = 'bbox.x' - length
    cutter = rect cutterWidth, 'bbox.y'
        .move (1-'is_output')*length + cutterWidth/2, 'bbox.y'/2
        # .fill color.activeArea
    port = pie -angle
        .rotate -Math.PI /2
        .move (bboxWidth*'is_output' + length*(1-'is_output')), bboxHeight/2
    port = port - cutter
    port = port.fill Color.rgb ['color_r', 'color_g', 'color_b']
    activeArea + port

flatPortSymbol = basegl.symbol flatPortExpr
flatPortSymbol.bbox.xy = [bboxWidth, bboxHeight]
flatPortSymbol.variables.color_r = 1
flatPortSymbol.variables.color_g = 0
flatPortSymbol.variables.color_b = 0
flatPortSymbol.variables.is_output = 0
flatPortSymbol.defaultZIndex = layers.flatPort

export class FlatPortShape extends BasicComponent
    initModel: =>
        color: [1,0,0]
        output: null
    define: => flatPortSymbol
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]
        if @changed.output
            x = if @model.output then (- bboxWidth) else 0
            element.variables.is_output = Number @model.output
            element.position.xy = [x, -bboxHeight/2]
