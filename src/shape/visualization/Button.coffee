import {BasicComponent} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'
import * as Color       from 'basegl/display/Color'
import {rect}           from 'basegl/display/Shape'
import * as color       from 'shape/Color'
import * as layers      from 'view/layers'

export width = 15
export height = 15

stripeWidth    = 0.8
stripeHeight   = 0.1
stripeDistance = 0.3

export buttonExpr = basegl.expr ->
    stripeW = 'bbox.x' * stripeWidth
    stripeH = 'bbox.y' * stripeHeight
    stripeD = 'bbox.y' * stripeDistance
    stripe = rect stripeW, stripeH
    stripe1 = stripe
        .move 'bbox.x'/2, 'bbox.y'/2 + stripeD
    stripe2 = stripe
        .move 'bbox.x'/2, 'bbox.y'/2
    stripe3 = stripe
        .move 'bbox.x'/2, 'bbox.y'/2 - stripeD
    activeArea = rect 'bbox.x', 'bbox.y'
        .move 'bbox.x'/2, 'bbox.y'/2
        .fill color.activeArea
    hamburger = stripe1 + stripe2 + stripe3
    hamburger = hamburger.fill color.visualizationMenu
    hamburger + activeArea

buttonSymbol = basegl.symbol buttonExpr
buttonSymbol.defaultZIndex = layers.textFrame
buttonSymbol.bbox.xy = [width, height]

export class VisualizerButton extends BasicComponent
    define: =>
        buttonSymbol
    adjust: (element) =>
        element.position.xy = [-width/2, -height/2]
