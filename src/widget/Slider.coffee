import * as basegl from 'basegl'

import {SliderShape} from 'shape/widget/Slider'
import {TextShape}   from 'shape/Text'
import * as layers   from 'view/layers'
import {Widget}      from 'widget/Widget'



class Slider extends Widget
    initModel: ->
        model = super()
        model.value = 0
        model.min = 0
        model.max = 1000
        model

    prepare: =>
        @__minWidth = 40
        @__minHeight = 20
        @addDef 'value', TextShape,
            fontFamily: 'DejaVuSansMono'
            size: 14
            align: 'center'
            text: '19'
        @addDef 'slider', SliderShape, null

    update: =>
        @updateDef 'value', text: @model.value.toString()
        @updateDef 'slider',
            level:       (@model.value - @model.min)/(@model.max - @model.min)
            topLeft:     not (@model.siblings.top or @model.siblings.left)
            topRight:    not (@model.siblings.top or @model.siblings.right)
            bottomLeft:  not (@model.siblings.bottom or @model.siblings.left)
            bottomRight: not (@model.siblings.bottom or @model.siblings.right)
            width:       @model.width
            height:      @model.height

    adjust: (view) =>
        if @changed.width  then @view('value').position.x = @model.width/2
        if @changed.height then @view('slider').position.y = -@model.height/2

    registerEvents: (view) =>
        @withScene (scene) =>
            canvas = scene.symbolModel._renderer.domElement
            view.addEventListener 'mousedown', (e) =>
                e.stopPropagation()
                canvas.requestPointerLock()
                onMouseMove = (e) =>
                    @set value: @nextValue e.movementX
                    @pushEvent
                        tag: 'PortControlEvent'
                        content:
                            cls: @cls
                            value: @model.value
                onMouseUp = =>
                    document.exitPointerLock()
                    document.removeEventListener 'mousemove', onMouseMove
                    document.removeEventListener 'mouseup', onMouseUp
                @addDisposableListener document, 'mouseup', onMouseUp
                @addDisposableListener document, 'mousemove', onMouseMove

export class DiscreteSlider extends Slider
    nextValue: (delta) => Math.round(@model.value + delta/2)
    cls: 'Int'

export class ContinousSlider extends Slider
    nextValue: (delta) => Math.round(@model.value * 10 + delta/2)/10
    cls: 'Real'
