import * as path         from 'path'

import * as style        from 'style'
import {Widget} from 'widget/Widget'
import {HtmlShape} from 'shape/Html'
import {VisualizerMenu}      from 'view/visualization/Menu'

width = 300
height = 300

export class VisualizationIFrame extends Widget
    initModel: =>
        key: null
        iframeId: null
        currentVisualizer: null
        mode: null

    prepare: =>
        @addDef 'menu', VisualizerMenu, null
        @addDef 'root', HtmlShape,
            element: 'div'
            top: false
            style:
                width: width + 'px'
                height: height + 'px'

    update: =>
        if @changed.currentVisualizer
            iframe = @__mkIframe()
            if iframe?
                domElem = @def('root').getDomElement()
                while domElem.hasChildNodes()
                    domElem.removeChild domElem.firstChild
                domElem.appendChild iframe
    adjust: =>
        @view('root').position.xy = [width/2, -height/2]

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

    registerEvents: =>
        updateMenu = => @updateDef 'menu',
            visualizers: @parent.parent.model.visualizers
        updateMenu()
        @addDisposableListener @parent.parent, 'visualizers', updateMenu
