import * as path         from 'path'

import * as style           from 'style'
import {HtmlShape}          from 'shape/Html'
import {ContainerComponent} from 'abstract/ContainerComponent'

width = 300
height = 300

export class VisualizationIFrame extends ContainerComponent
    initModel: =>
        key: null
        iframeId: null
        currentVisualizer: null
        mode: 'Preview' # Default|Focused|Preview

    prepare: =>
        @addDef 'root', HtmlShape,
            element: 'div'
            width: width + 'px'
            height: height + 'px'

    __isModeDefault: => @model.mode == 'Default'
    __isModePreview: => @model.mode == 'Preview'

    __width: =>
        if @__isModePreview() then @root._scene.width else width

    __height: =>
        if @__isModePreview() then @root._scene.height else height

    update: =>
        if @changed.mode
            @updateDef 'root',
                clickable: not @__isModeDefault()
                top: not @__isModeDefault()
                scalable: not @__isModePreview()
                still: @__isModePreview()
                width: @__width() + 'px'
                height: @__height() + 'px'

        if @changed.currentVisualizer or @changed.iframeId
            iframe = @__mkIframe()
            if iframe?
                domElem = @def('root').getDomElement()
                while domElem.hasChildNodes()
                    domElem.removeChild domElem.firstChild
                domElem.appendChild iframe

    adjust: (view) =>
        if @changed.mode
            if @__isModePreview()
                @view('root').position.xy = [@__width()/2, @__height()/2]
            else
                @view('root').position.xy = [@__width()/2, - @__height()/2]

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
