import {nodeSelectionBorderMaxSize} from 'shape/node/Base'
import {BasicComponent}             from 'abstract/BasicComponent'

export angle = Math.PI/3
export length    = 10
export width     = length * Math.tan angle
export distanceFromCenter = nodeSelectionBorderMaxSize
export inArrowRadius    = length + distanceFromCenter
export outArrowRadius    = distanceFromCenter


export class PortShape extends BasicComponent
    initModel: => color: [1,0,0]
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]

    registerEvents: (view) =>
        view.addEventListener 'mouseover', => @__element.variables.hovered = 1
        view.addEventListener 'mouseout',  => @__element.variables.hovered = 0
