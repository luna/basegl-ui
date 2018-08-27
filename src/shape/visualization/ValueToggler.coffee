import * as basegl         from 'basegl'
import {rect, triangle}    from 'basegl/display/Shape'
import {BasicComponent}    from 'abstract/BasicComponent'
import * as color          from 'shape/Color'
import * as baseNode       from 'shape/node/Base'
import * as layers         from 'view/layers'


export size = 10

valueTogglerExpr = basegl.expr ->
    activeArea = rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.activeArea
    isFolded = 'isFolded'
    button = triangle size, size
        .fill color.valueTogglerColor
        .rotate isFolded * Math.PI
        .moveX size/2
        .moveY isFolded * size
    button + activeArea
valueTogglerSymbol         = basegl.symbol valueTogglerExpr
valueTogglerSymbol.defaultZIndex = layers.valueToggler
valueTogglerSymbol.bbox.xy = [size, size]
valueTogglerSymbol.variables.isFolded = 0

export class ValueTogglerShape extends BasicComponent
    initModel: =>
        isFolded: false
    define: => valueTogglerSymbol
    adjust: (element) =>
        if @changed.isFolded
            element.variables.isFolded = Number @model.isFolded
        element.position.xy = [- size/2, - size/2]
