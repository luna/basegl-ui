import {BasicComponent, memoizedSymbol} from 'abstract/BasicComponent'
import * as basegl                      from 'basegl'
import * as Color                       from 'basegl/display/Color'
import {rect}                           from 'basegl/display/Shape'
import * as color                       from 'shape/Color'
import {shadowExpr}                     from 'shape/Shadow'
import * as layers                      from 'view/layers'

size = (style) -> style.visualizationControl_size
bboxSize = (style) -> size(style) + 2*style.visualizationControl_shadow

stripeHeight   = (style) -> 0.15 * size(style)
stripeDistance = (style) -> (size(style) - 3 * stripeHeight(style)) / 2 + stripeHeight(style)

buttonExpr = (style) -> basegl.expr ->
    stripeW = size style
    stripeH = stripeHeight style
    stripeD = stripeDistance style
    stripe = rect stripeW, stripeH
    stripe1 = stripe.moveY stripeD
    stripe2 = stripe
    stripe3 = stripe.moveY -stripeD
    hamburger = (stripe1 + stripe2 + stripe3)
        .fill color.visualizationMenu
    activeArea = rect 'bbox.x', 'bbox.y'
        .fill color.activeArea
    shadow = shadowExpr hamburger, style.visualizationControl_shadow, style
    (hamburger + shadow + activeArea).move 'bbox.x'/2, 'bbox.y'/2

buttonSymbol = memoizedSymbol (style) ->
    symbol = basegl.symbol buttonExpr style
    symbol.defaultZIndex = layers.textFrame
    symbol.bbox.xy = [bboxSize(style), bboxSize(style)]
    symbol

export class VisualizerButton extends BasicComponent
    define: =>
        buttonSymbol @style
    adjust: (element) =>
        element.position.xy = [-bboxSize(@style)/2, -bboxSize(@style)/2]
