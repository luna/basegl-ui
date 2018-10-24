import {Widget}  from 'widget/Widget'


export class Placeholder extends Widget
    initModel: =>
        constWidth: null
        constHeight: null

    update: =>
        if @changed.constHeight
            @__minHeight = @model.constHeight
            @__maxHeight = @model.constHeight
        if @changed.constWidth
            @__minWidth = @model.constWidth
            @__maxWidth = @model.constWidth
