import * as path         from 'path'

import * as style                from 'style'
import {Widget}                  from 'widget/Widget'
import {HtmlShape}               from 'shape/Html'
import {Background}              from 'shape/node/Background'
import * as menuShape            from 'shape/visualization/Button'
import {VisualizationCoverShape} from 'shape/visualization/Cover'
import {VisualizationIFrame}     from 'view/visualization/IFrame'
import {VisualizerMenu}          from 'view/visualization/Menu'

iframeYOffset = 5

export class Visualization extends Widget
    initModel: =>
        model = super()
        model.key = null
        model.iframeId = null
        model.currentVisualizer = null
        model.mode = null
        model

    prepare: =>
        @addDef 'menu', VisualizerMenu
        @addDef 'cover', VisualizationCoverShape
        @addDef 'iframe', VisualizationIFrame
        @addDef 'background', Background,
            height: @style.visualization_height
            width: @style.visualization_width
            invisible: true

    update: =>
        if @changed.siblings
            @updateDef 'background',
                roundTop:    not @model.siblings.top
                roundBottom: not @model.siblings.bottom
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
            @view('menu').position.xy = [ @style.visualization_menuX, @style.visualization_menuY]
            @view('iframe').position.xy = [@style.node_widgetOffset_h, -@style.node_widgetOffset_v]
    connectSources: =>
        updateMenu = => @updateDef 'menu',
            visualizers: @parent.parent.model.visualizers
        updateMenu()
        @addDisposableListener @parent.parent, 'visualizers', updateMenu

    registerEvents: =>
        @view('cover').addEventListener 'mousedown', (e) =>
            e.stopPropagation()
            @pushEvent tag: 'FocusVisualizationEvent'
