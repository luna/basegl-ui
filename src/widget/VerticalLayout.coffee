import {FlatLayout}   from 'abstract/Layout'
import {lookupWidget} from 'widget/WidgetDirectory'


export class VerticalLayout extends FlatLayout
    __updateChildren: =>
        return unless @model.children.length > 0
        children = []
        @__minHeight = 0
        @__maxHeight = 0
        @__minWidth = 0
        @__maxWidth = Infinity
        @forEach (def, key, i) =>
            children.push
                key    : key
                index  : i
                widget : def
                height : def.minHeight()
            defMinHeight = def.minHeight() or 0
            if defMinHeight > 0 && @__minHeight > 0
                defMinHeight += @model.offset
            defMaxHeight = def.maxHeight() or 0
            if defMaxHeight > 0 && @__maxHeight > 0
                defMaxHeight += @model.offset
            @__minHeight += defMinHeight
            @__maxHeight += defMaxHeight
            @__minWidth = Math.max def.minWidth(), @__minWidth
            @__maxWidth = Math.min def.maxWidth(), @__maxWidth
            @updateDef key, siblings:
                top:  ! (i == 0)
                bottom: ! (i == @model.children.length - 1)
        if @model.height?
            free = @model.height - @__minHeight
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
        @positions = {}
        children.forEach (w) =>
            @positions[w.key] = startPoint.slice()
            @setPosition @view(w.key), startPoint
            @updateDef w.key,
                height: w.height
                width: @__computeWidth w.widget
            if w.height > 0
                startPoint[1] -= w.height + @model.offset

    __computeWidth: (widget) =>
        width = @model.width or @minWidth()
        if width < widget.maxWidth()
            width
        else
            widget.maxWidth()
