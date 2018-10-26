import {BasicComponent} from 'abstract/BasicComponent'


export width     = (style) -> style.port_length * Math.tan style.port_angle
export distanceFromCenter = (style) -> style.node_radius + style.port_distance
export inArrowRadius  = (style) -> style.port_length + distanceFromCenter(style)
export outArrowRadius = (style) -> distanceFromCenter(style)
export offset = (style) -> style.port_length - 2


export class PortShape extends BasicComponent
    initModel: =>
        color: [1,0,0]
        connected: false

    adjust: (element) =>
        if @changed.connected
            element.variables.connected = Number @model.connected
        if @changed.color
            element.variables.color_r = @model.color[0]
            element.variables.color_g = @model.color[1]
            element.variables.color_b = @model.color[2]

    registerEvents: (view) =>
        animateHover = (value) =>
            @animateVariable 'hovered', value
        view.addEventListener 'mouseover', => animateHover 1
        view.addEventListener 'mouseout',  => animateHover 0
