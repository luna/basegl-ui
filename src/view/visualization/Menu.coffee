import * as _ from 'underscore'

import {ContainerComponent} from 'abstract/ContainerComponent'
import {VisualizerButton}   from 'shape/visualization/Button'
import {TextContainer}      from 'view/Text'
import {VerticalLayout}     from 'widget/VerticalLayout'


listPosition = [10, -15]
menuItemColor = [0, 0, 0]
menuSelectedItemColor = [0.2, 0.2, 0.2]
menuItemsSpacing = 0
menuItemBorder = 5

export class VisualizerMenu extends ContainerComponent
    initModel: =>
        visualizers : null
        selected: null
        menuVisible: false

    prepare: =>
        @addDef 'button', VisualizerButton, null

    update: =>
        if @changed.menuVisible or @changed.visualizers or @changed.selected
            if @model.visualizers?
                children = @model.visualizers.map (visualizer) =>
                    cons: TextContainer
                    text: visualizer.visualizerName
                    align: 'right'
                    border: menuItemBorder
                    frameColor: if _.isEqual visualizer, @model.selected then menuSelectedItemColor else menuItemColor
                    onclick: (e) =>
                        e.stopPropagation()
                        @pushEvent
                            tag: 'SelectVisualizerEvent'
                            visualizerId: visualizer
                        @set menuVisible: false
                @autoUpdateDef 'list', VerticalLayout, if @model.menuVisible
                    offset: menuItemsSpacing
                    children: children
    adjust: =>
        @view('list')?.position.xy = listPosition

    registerEvents: =>
        @view('button').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @set menuVisible: not @model.menuVisible
