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
        expanded: false

    prepare: =>
        @addDef 'button', VisualizerButton, null

    update: =>
        if @changed.expanded or @changed.visualizers or @changed.selected
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
                @autoUpdateDef 'list', VerticalLayout, if @model.expanded
                    offset: menuItemsSpacing
                    children: children
    adjust: =>
        @view('list')?.position.xy = listPosition

    registerEvents: =>
        @view('button').addEventListener 'click', (e) =>
            e.stopImmediatePropagation()
            @set expanded: not @model.expanded
            setTimeout =>
                @addDisposableListener window, 'click', @__hideMenu


    __hideMenu: =>
        @set expanded: false
        window.removeEventListener 'click', @__hideMenu
