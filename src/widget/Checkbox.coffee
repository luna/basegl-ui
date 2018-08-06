import {CheckboxShape} from 'shape/widget/Checkbox'
import * as layers   from 'view/layers'
import {Widget}      from 'widget/Widget'


export class Checkbox extends Widget
    initModel: ->
        model = super()
        model.value = false
        model

    prepare: =>
        @addDef 'checkbox', new CheckboxShape null, @

    minHeight: => 20
    minWidth: => 20
    maxHeight: => 20
    maxWidth: => 50
    update: =>
        @updateDef 'checkbox',
            checked:     @model.value
            topLeft:     not (@model.siblings.top or @model.siblings.left)
            topRight:    not (@model.siblings.top or @model.siblings.right)
            bottomLeft:  not (@model.siblings.bottom or @model.siblings.left)
            bottomRight: not (@model.siblings.bottom or @model.siblings.right)
            width:       @model.width
            height:      @model.height

    adjust: (view) =>
        if @changed.height then @view('checkbox').position.y = -@model.height/2

    registerEvents: (view) =>
        view.addEventListener 'mousedown', (e) =>
            e.stopPropagation()
        view.addEventListener 'click', (e) =>
            @set value: not @model.value
            @pushEvent
                tag: 'PortControlEvent'
                content:
                    cls: 'Bool'
                    value: @model.value
