import {ContainerComponent}  from 'abstract/ContainerComponent'
import {ValueTogglerShape}   from 'shape/visualization/ValueToggler'
import {TextContainer}       from 'view/Text'
import {Visualization}       from 'view/visualization/Visualization'
import {VerticalLayout}      from 'widget/VerticalLayout'
import {Parameters}         from 'view/Parameters'



export class NodeBody extends ContainerComponent
    initModel: =>
        expanded: false
        inPorts: {}
        controls: {}
        newPortKey: null
        visualizers : null
        visualizations: {}
        value: null

    prepare: =>
        @addDef 'valueToggler', ValueTogglerShape
        @addDef 'body', VerticalLayout,
            width: @style.node_bodyWidth

    update: =>
        if @changed.value
            @updateDef 'valueToggler',
                isFolded: @model.value?.contents?.tag != 'Visualization'
        if @changed.visualizations or @changed.visualizers or @changed.inPorts or @changed.controls or @changed.newPortKey or @changed.expanded or @changed.value
            body = []
            modules = []
            if @model.expanded
                modules.push
                    id: 'parameters'
                    cons: Parameters
                    inPorts: @model.inPorts
                    controls: @model.controls
                    newPortKey: @model.newPortKey
            for own k, visualization of @model.visualizations
                visualization.cons = Visualization
                visualization.visualizers = @model.visualizers
                modules.push visualization
            body.push
                id: 'modules'
                cons: VerticalLayout
                children: modules
            if @__shortValue()?
                body.push
                    id: 'value'
                    cons: TextContainer
                    textAlign: 'center'
                    valign: 'top'
                    color: [@style.text_color_r, @style.text_color_g, @style.text_color_b]
                    text: @__shortValue()

            @updateDef 'body', children: body

    adjust: =>
        @view('value')?.position.xy =
            [@style.node_bodyWidth/2, -@style.node_valueOffset]
        @view('valueToggler').position.xy =
            [ @style.visualization_togglerX, @style.visualization_togglerY ]
    
    registerEvents: =>
        @view('valueToggler').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent tag: 'ToggleVisualizationsEvent'

    __shortValue: =>
        @model.value?.contents?.contents

    portPosition: (key) =>
        @__defs.body.positions['modules'][1] \
        + @__defs.body.__defs.modules.positions['parameters'][1] \
        + @__defs.body.__defs.modules.__defs.parameters.__defs.widgets.positions[key][1]
