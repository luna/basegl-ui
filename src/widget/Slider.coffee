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
            fontFamily: 'SourceCodePro'
            color:    [@style.text_color_r, @style.text_color_g, @style.text_color_b]
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

    adjust: (view) => # TODO: merge this function with update? Remove adjust?
        if @changed.width  then @view('value').position.x = @model.width/2
        if @changed.height then @view('slider').position.y = -@model.height/2

    registerEvents: (view) =>
        canvas = @root.scene.symbolModel._renderer.domElement
        view.addEventListener 'mousedown', (e) =>
            return unless e.button == 0
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

contPrec = 100
mousePrec = 5

export class DiscreteSlider extends Slider
    nextValue: (delta) =>
        if Math.round(@__internalValue / mousePrec) != @model.value
            @__internalValue = @model.value * mousePrec
        @__internalValue += delta
        Math.round(@__internalValue / mousePrec)
    cls: 'Int'

export class ContinousSlider extends Slider
    nextValue: (delta) =>
        if Math.round(@__internalValue / mousePrec) / contPrec != @model.value
            @__internalValue = @model.value * mousePrec * contPrec
        @__internalValue += delta
        Math.round(@__internalValue / mousePrec) / contPrec
    cls: 'Real'
