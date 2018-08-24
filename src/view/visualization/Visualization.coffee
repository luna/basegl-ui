import * as path         from 'path'

import * as style                from 'style'
import {Widget}                  from 'widget/Widget'
import {HtmlShape}               from 'shape/Html'
import {VisualizationIFrame}     from 'view/visualization/IFrame'
import {VisualizerMenu}          from 'view/visualization/Menu'
import * as menuShape            from 'shape/visualization/Button'
import {VisualizationCoverShape} from 'shape/visualization/Cover'

iframeYOffset = 5

export class Visualization extends Widget
    initModel: =>
        key: null
        iframeId: null
        currentVisualizer: null
        mode: null

    prepare: =>
        @addDef 'menu', VisualizerMenu
        @addDef 'cover', VisualizationCoverShape
        @addDef 'iframe', VisualizationIFrame

    update: =>
        if @changed.currentVisualizer or @changed.iframeId or @changed.mode
            @updateDef 'iframe',
                iframeId: @model.iframeId
                currentVisualizer: @model.currentVisualizer
                mode: @model.mode
        if @changed.currentVisualizer
            @updateDef 'menu',
                selected: @model.currentVisualizer.visualizerId

    adjust: =>
        if @changed.once
            @view('iframe').position.xy = [- menuShape.width/2, - menuShape.height/2 - iframeYOffset]
            @view('cover').position.xy = [- menuShape.width/2, - menuShape.height/2 - iframeYOffset]

    connectSources: =>
        updateMenu = => @updateDef 'menu',
            visualizers: @parent.parent.model.visualizers
        updateMenu()
        @addDisposableListener @parent.parent, 'visualizers', updateMenu

    registerEvents: =>
        @view('cover').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent tag: 'FocusVisualizationEvent'
