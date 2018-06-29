import {BasicComponent} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'

export width     = 30

lineWidth = 2

export connectionExpr = basegl.expr ->
    eye         = 'scaledEye.z'
    scaledWidth = lineWidth * Math.pow(Math.clamp(eye*20.0, 0.0, 400.0),0.85) / 10
    scaledWidth = scaledWidth + scaledWidth * 'hovered'
    activeArea = rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.activeArea
    connection = rect 'bbox.x', scaledWidth
       .move 'bbox.x'/2, 'bbox.y'/2
       .fill color.varHover()
    activeArea + connection

connectionSymbol = basegl.symbol connectionExpr
connectionSymbol.defaultZIndex = layers.connection
connectionSymbol.bbox.y = width
connectionSymbol.variables.color_r = 1
connectionSymbol.variables.color_g = 0
connectionSymbol.variables.color_b = 0
connectionSymbol.variables.hovered = 0

export class ConnectionShape extends BasicComponent
    initModel: =>
        offset: 0
        length: 0
        angle: 0
        color: [1,0,0]

    define: =>
        connectionSymbol

    adjust: (element, view) =>
        if @changed.length
            element.bbox.x = @model.length
        if @changed.offset
            element.position.x = @model.offset
        element.position.y = - width/2
        if @changed.angle
            element.rotation.z = @model.angle
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]

    registerEvents: (view) =>
        view.addEventListener 'mouseover', => @__element.variables.hovered = 1
        view.addEventListener 'mouseout',  => @__element.variables.hovered = 0
