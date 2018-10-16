import * as basegl                      from 'basegl'
import {rect, triangle}                 from 'basegl/display/Shape'
import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as color                       from 'shape/Color'
import * as baseNode                    from 'shape/node/Base'
import * as layers                      from 'view/layers'
import {shadowExpr}                     from 'shape/Shadow'

size = (style) -> style.visualizationControl_size
bboxSize = (style) -> size(style) + 2*style.visualizationControl_shadow

valueTogglerExpr = (style) -> basegl.expr ->
    activeArea = rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.activeArea
    isFolded = 'isFolded'
    button = triangle size(style), size(style)
        .fill color.valueTogglerColor
        .rotate isFolded * Math.PI
        .moveX bboxSize(style)/2
        .moveY isFolded * size(style) + style.visualizationControl_shadow
    shadow = shadowExpr button, style.visualizationControl_shadow, style
    button + shadow + activeArea

valueTogglerSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol valueTogglerExpr style
    symbol.defaultZIndex = layers.valueToggler
    symbol.bbox.xy = [bboxSize(style), bboxSize(style)]
    symbol.variables.isFolded = 0
    symbol

export class ValueTogglerShape extends BasicComponent
    initModel: =>
        isFolded: false
    define: => valueTogglerSymbol @style
    adjust: (element) =>
        if @changed.isFolded
            element.variables.isFolded = Number @model.isFolded
        element.position.xy = [- bboxSize(@style)/2, - bboxSize(@style)/2]
