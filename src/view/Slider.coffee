import * as basegl from 'basegl'

import * as shape  from 'shape/Slider'
import * as layers from 'view/layers'
import {Widget}    from 'view/Widget'
import * as util   from 'shape/util'


sliderShape = basegl.symbol shape.sliderShape
sliderShape.defaultZIndex = layers.slider
sliderShape.bbox.xy = [100, 20]
sliderShape.variables.level = 0
sliderShape.variables.topLeft     = 0
sliderShape.variables.topRight    = 0
sliderShape.variables.bottomLeft  = 0
sliderShape.variables.bottomRight = 0

export class Slider extends Widget
    constructor: (args...) ->
        super args...
        @configure
            minWidth: 40
            minHeight: 20
            width: 100

    updateModel: ({ min:   @min   = @min
                  , max:   @max   = @max
                  , value: value  = @value
                  , position: @position = @position or [0,0]
                  }) =>
        if @def?
            if value != @value
                @value = value
                @createDef()
                @reattach()
        else
            @value = value
            @createDef()

    createDef: =>
        valueShape = util.text
            str: @value.toString()
            fontFamily: 'DejaVuSansMono'
            size: 14
        @def = [ {name: 'slider', def: sliderShape}
               , {name: 'value',  def: valueShape} ]

    updateView: =>
        @element.slider.variables.level = (@value - @min)/(@max - @min)
        @element.slider.variables.topLeft     = Number not (@siblings.top or @siblings.left)
        @element.slider.variables.topRight    = Number not (@siblings.top or @siblings.right)
        @element.slider.variables.bottomLeft  = Number not (@siblings.bottom or @siblings.left)
        @element.slider.variables.bottomRight = Number not (@siblings.bottom or @siblings.right)
        @element.slider.bbox.xy = [@width, @height]
        textSize = util.textSize @element.value
        @view.value.position.xy = [@width/2 - textSize[0]/2 , @height/2 - textSize[1]/2]
        @group.position.xy = [@position[0], @position[1] - @height/2]

    registerEvents: =>
