import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {circle}         from 'basegl/display/Shape'
import {BasicComponent} from 'abstract/BasicComponent'
import * as color       from 'shape/Color'
import {length}         from 'shape/port/Base'
import * as layers      from 'view/layers'


radius = length
export width = 2 * radius
export height = 2 * radius

export selfPortExpr = basegl.expr ->
    c = circle radius
       .move radius, radius
       .fill color.varHover()

selfPortSymbol = basegl.symbol selfPortExpr
selfPortSymbol.bbox.xy = [width, height]
selfPortSymbol.variables.color_r = 1
selfPortSymbol.variables.color_g = 0
selfPortSymbol.variables.color_b = 0
selfPortSymbol.variables.hovered = 0
selfPortSymbol.defaultZIndex = layers.selfPort

export class SelfPortShape extends BasicComponent
    initModel: => color: [1,0,0]
    define: => selfPortSymbol
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]
        element.position.xy = [-width/2, -height/2]

    registerEvents: (view) =>
        view.addEventListener 'mouseover', => @__element.variables.hovered = 1
        view.addEventListener 'mouseout',  => @__element.variables.hovered = 0
