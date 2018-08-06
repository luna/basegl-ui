import {ContainerComponent} from 'abstract/ContainerComponent'
import {lookupWidget}       from 'widget/WidgetDirectory'


export class VerticalLayout extends ContainerComponent
    initModel: =>
        key: null
        children: []
        height: null
        width: null
        offset: 3

    update: =>
        if @changed.children
            for own k, widget of @model.children
                cons = lookupWidget widget
                if cons?
                    @autoUpdateDef k, cons, widget

        return unless @model.children.length > 0
        children = []
        @__minHeight = 0
        @__maxHeight = 0
        @__minWidth = 0
        @__maxWidth = Infinity
        for i in [0..@model.children.length - 1]
            children.push
                index  : i
                widget : @def(i)
                height : @def(i).minHeight()
            @__minHeight += @def(i).minHeight() or 0
            @__maxHeight += @def(i).maxHeight() or 0
            @__minWidth = Math.min @def(i).minWidth(), @__minWidth
            @__maxWidth = Math.max @def(i).maxWidth(), @__maxWidth
            @updateDef i, siblings:
                left:  ! (i == 0)
                right: ! (i == @model.children.length - 1)
        if @model.height?
            free = @model.height - @__minHeight - @model.offset * (@model.children.length - 1)
            children.sort (a, b) -> a.widget.maxHeight() - b.widget.maxHeight()
            for i in [0..children.length - 1]
                w = children[i]
                wfree = free / (children.length - i)
                if (! w.widget.maxHeight()?) or w.widget.maxHeight() > w.height + wfree
                    free -= wfree
                    w.height += wfree
                else
                    free -= w.widget.maxHeight() - w.height
                    w.height = w.widget.maxHeight()
            children.sort (a, b) -> a.index - b.index

        startPoint = [0,0]
        children.forEach (w) =>
            @view(w.index).position.xy = startPoint.slice()
            @updateDef w.index,
                height: w.height
                width: @__computeWidth w.widget
            startPoint[1] += w.height + @model.offset

    __computeWidth: (widget) =>
        width = @model.width
        if width < widget.maxWidth()
            width
        else
            widget.maxWidth()
