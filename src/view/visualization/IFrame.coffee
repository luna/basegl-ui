import * as path         from 'path'

import * as style           from 'style'
import {HtmlShapeWithScene} from 'shape/Html'
import {ContainerComponent} from 'abstract/ContainerComponent'


export class VisualizationIFrame extends ContainerComponent
    @iframeIdx = 0
    @rootViewName = 'root'
    @rootDefName  = 'root'

    initModel: =>
        key: null
        iframeId: null
        currentVisualizer: null
        mode: 'Default' # Default|Focused|Preview

    prepare: =>
        id = 'iframe-containter-' + VisualizationIFrame.iframeIdx
        VisualizationIFrame.iframeIdx += 1
        @addDef VisualizationIFrame.rootDefName, HtmlShapeWithScene,
            id: id
            element: 'div'
            clickable: false

        @html = @def(VisualizationIFrame.rootDefName)
        @sceneId = "basegl-root-layer-" + @html.sceneId
        @scene   = document.getElementById(@sceneId)

    __isModeDefault: => @model.mode == 'Default'
    __isModeFocused: => @model.mode == 'Focused'
    __isModePreview: => @model.mode == 'Preview'

    __width: =>
        if @__isModePreview() then @root.scene.width else @style.visualization_width - 2* @style.node_widgetOffset_h

    __height: =>
        if @__isModePreview() then @root.scene.height else @style.visualization_height - 2* @style.node_widgetOffset_v

    update: =>
        if @changed.mode
            if @model.mode == 'Preview'
                @html.makeStill()
            else
                @html.makeMovable()
        if @changed.iframeId
            @updateDef VisualizationIFrame.rootDefName,
                id: @model.iframeId


        if @changed.currentVisualizer
            @iframe = @__mkIframe()
            if @iframe?
                domElem = @html.getDomElement()
                while domElem.hasChildNodes()
                    domElem.removeChild domElem.firstChild
                domElem.appendChild @iframe
        if @changed.iframeId
            @iframe?.name = @model.iframeId
        @iframe?.style.width  = @__width() + 'px'
        @iframe?.style.height = @__height() + 'px'

    adjust: (view) =>
        if @changed.mode
            @scene?.style.zIndex = if @__isModeDefault() then 0 else 10

            if @__isModePreview()
                @html.__removeFromGroup @html.__element
                @html.__element.position.xy = [@__width()/2, @__height()/2]
            else
                @html.__addToGroup @html.__element
                @html.__element.position.xy = [0,0]

            @view(VisualizationIFrame.rootViewName).position.xy =
                [@__width() / 2, -@__height() / 2]

    __mkIframe: =>
        if @model.currentVisualizer?
            visPaths = @root.visualizerLibraries
            visType = @model.currentVisualizer.visualizerId.visualizerType
            pathPrefix = if visType == 'InternalVisualizer'
                    visPaths.internalVisualizersPath
                else if visType == 'LunaVisualizer'
                    visPaths.lunaVisualizersPath
                else visPaths.projectVisualizersPath

        if pathPrefix?
            url = path.join pathPrefix, @model.currentVisualizer.visualizerPath

        if url?
            iframe           = document.createElement 'iframe'
            iframe.className = style.luna ['basegl-visualization-iframe']
            iframe.src       = url
            iframe

    registerEvents: (view) =>
        # FOR DEBUG PURPOSES:
        if window.DEBUG
            window.addEventListener 'keyup', (event) =>
                if event.key == 'z'
                    @set(mode: 'Default')
                if event.key == 'x'
                    @set(mode: 'Focused')
                if event.key == 'c'
                    @set(mode: 'Preview')
