import {InPortShape} from 'shape/port/In'


export class NewPortShape extends InPortShape
    initModel: =>
        model = super()
        model.lockHover = false
        model

    adjust: (element) =>
        super element
        if @changed.lockHover
            element.variables.color_a = @__alphaOnUnhover()

    __alphaOnUnhover: => Number @model.lockHover

    registerEvents: (view) =>
        view.addEventListener 'mouseover', => @getElement().variables.color_a = 1
        view.addEventListener 'mouseout',  => @getElement().variables.color_a = @__alphaOnUnhover()
