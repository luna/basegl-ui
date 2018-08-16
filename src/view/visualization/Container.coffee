import {ContainerComponent}  from 'abstract/ContainerComponent'
import {ValueTogglerShape}   from 'shape/visualization/ValueToggler'
import {TextContainer}       from 'view/Text'
import {VisualizationIFrame} from 'view/visualization/IFrame'
import {VerticalLayout}      from 'widget/VerticalLayout'

valueLeftOffset   = 50
togglerLeftOffset = 30

export class VisualizationContainer extends ContainerComponent
    initModel: =>
        visualizers : null
        visualizations: {}
        value: null

    prepare: =>
        @addDef 'valueToggler', ValueTogglerShape, null

    update: =>
        if @changed.value
            @autoUpdateDef 'value', TextContainer, if @__shortValue()?
                text: @__shortValue()
            @updateDef 'valueToggler',
                isFolded: @model.value?.contents?.tag != 'Visualization'
        if @changed.visualizations or @changed.visualizers
            visualizations = []
            if @model.visualizations?
                for k, visualization of @model.visualizations
                    visualization.visualizers = @model.visualizers
                    visualization.cons = VisualizationIFrame
                    visualizations.push visualization
            @autoUpdateDef 'visualizations', VerticalLayout, if visualizations.length > 0
                children: visualizations

    adjust: =>
        @view('value')?.position.x = valueLeftOffset
        @view('valueToggler').position.xy = togglerLeftOffset

    registerEvents: =>
        @view('valueToggler').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent tag: 'ToggleVisualizationsEvent'

    __shortValue: =>
        @model.value?.contents?.contents

