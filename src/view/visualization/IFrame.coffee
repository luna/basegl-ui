import * as path         from 'path'

import * as style        from 'style'
import {Widget}          from 'widget/Widget'
import {HtmlShape}       from 'shape/Html'

width = 300
height = 300

export class VisualizationIFrame extends Widget
    initModel: =>
        key: null
        iframeId: null
        currentVisualizer: null
        mode: 'Default' # Default|Focused|Fullscreen

    prepare: =>
        @addDef 'root', HtmlShape,
            element: 'div'
            width: width + 'px'
            height: height + 'px'

    __isModeDefault:    => @model.mode == 'Default'
    __isModeFullscreen: => @model.mode == 'Fullscreen'

    update: =>
        if @changed.mode
            @updateDef 'root',
                clickable: not @__isModeDefault()
                top: not @__isModeDefault()
                scalable: not @__isModeFullscreen()

        if @changed.currentVisualizer or @changed.iframeId
            iframe = @__mkIframe()
            if iframe?
                domElem = @def('root').getDomElement()
                while domElem.hasChildNodes()
                    domElem.removeChild domElem.firstChild
                domElem.appendChild iframe

    adjust: =>
        if @changed.once
            @view('root').position.xy = [width/2, - height/2]

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
            iframe.name      = @model.iframeId
            iframe.className = style.luna ['basegl-visualization-iframe']
            iframe.src       = url
            iframe
