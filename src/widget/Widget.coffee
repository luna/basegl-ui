import * as basegl    from 'basegl'

import {ContainerComponent}  from 'abstract/ContainerComponent'
import {Component}  from 'abstract/Component'


export class Widget extends ContainerComponent
    initModel: =>
        width:     null
        height:    null
        inline:    false
        siblings:
            top:    false
            bottom: false
            left:   false
            right:  false

    minWidth: => @__minWidth or 0
    optWidth: => @__optWidth or 100
    maxWidth: => @__maxWidth or Infinity

    minHeight: => @__minHeight or 0
    optHeight: => @__optHeight or 100
    maxHeight: => @__maxHeight or Infinity

export class WidgetOld extends Component
    configure: ({ minWidth:  @minWidth  = @minWidth or 0
                , minHeight: @minHeight = @minHeight or 0
                , maxWidth:  @maxWidth  = @maxWidth
                , maxHeight: @maxHeight = @maxHeight
                , width:     @width  = @width
                , height:    @height = @height
                , inline:    @inline = @inline or false
                , siblings:  @siblings = @siblings or {}
                }) =>
        @width ?= @minWidth
        @height ?= @minHeight
        @siblings.top    ?= false
        @siblings.bottom ?= false
        @siblings.left   ?= false
        @siblings.right  ?= false
        @updateView() if @view?
