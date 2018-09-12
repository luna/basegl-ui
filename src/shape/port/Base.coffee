import {BasicComponent}             from 'abstract/BasicComponent'

export width     = (style) -> style.port_length * Math.tan style.port_angle
export distanceFromCenter = (style) -> style.node_selectionBorderMaxSize + style.port_distance
export inArrowRadius  = (style) -> style.port_length + distanceFromCenter(style)
export outArrowRadius = (style) -> distanceFromCenter(style)
export offset = (style) -> style.port_length - 2


export class PortShape extends BasicComponent
    initModel: => color: [1,0,0]
    adjust: (element) =>
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]

    registerEvents: (view) =>
        view.addEventListener 'mouseover', => @getElement().variables.hovered = 1
        view.addEventListener 'mouseout',  => @getElement().variables.hovered = 0
