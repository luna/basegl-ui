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
        console.log 'UPDATE', @changed
        if @changed.mode
            @updateDef 'root',
                clickable: not @__isModeDefault()
                top: not @__isModeDefault()
                scalable: not @__isModePreview()
                still: @__isModePreview()
                width: @__width() + 'px'
                height: @__height() + 'px'

        if @changed.currentVisualizer
            @iframe = @__mkIframe()
            if @iframe?
                domElem = @def('root').getDomElement()
                while domElem.hasChildNodes()
                    domElem.removeChild domElem.firstChild
                domElem.appendChild @iframe
        if @changed.iframeId
            @iframe?.name = @model.iframeId

    adjust: (view) =>
        if @changed.mode
            yPos = @__height()/2 * if @__isModePreview() then 1 else -1
            @view('root').position.xy = [@__width()/2, yPos]

    __mkIframe: =>
        console.log '__mkIframe', @changed.currentVisualizer, @changed.iframeId, @model.currentVisualizer, @model.iframeId
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
            iframe.style.width  = @__width() + 'px'
            iframe.style.height = @__height() + 'px'
            iframe.src       = url
            iframe
