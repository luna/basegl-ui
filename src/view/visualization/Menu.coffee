import {ContainerComponent} from 'abstract/ContainerComponent'
import {VisualizerButton}   from 'shape/visualization/Button'
import {TextContainer}      from 'view/Text'
import {VerticalLayout}     from 'widget/VerticalLayout'


listPosition = [10, -15]

export class VisualizerMenu extends ContainerComponent
    initModel: =>
        key: null
        visualizers : null
        menuVisible: false

    prepare: =>
        @addDef 'button', VisualizerButton, null

    update: =>
        if @changed.menuVisible or @changed.visualizers
            if @model.visualizers?
                children = @model.visualizers.map (visualizer) =>
                    cons: TextContainer
                    text: visualizer.visualizerName
                    align: 'right'
                    onclick: (e) =>
                        e.stopPropagation()
                        @pushEvent
                            tag: 'SelectVisualizerEvent'
                            visualizerId: visualizer
                        @set menuVisible: false
                @autoUpdateDef 'list', VerticalLayout, if @model.menuVisible
                    children: children
    adjust: =>
        @view('list')?.position.xy = listPosition

    registerEvents: =>
        @view('button').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @set menuVisible: not @model.menuVisible
