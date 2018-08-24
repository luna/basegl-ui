import {BasicComponent}  from 'abstract/BasicComponent'
import * as basegl       from 'basegl'


export class HtmlShape extends BasicComponent
    initModel: =>
        id: null
        element: 'div'
        width: null
        height: null
        top: true
        scalable: true
        still: false
        clickable: true

    redefineRequired: => @changed.element

    define: =>
        @html = document.createElement @model.element
        basegl.symbol @html

    adjust: =>
        # if @changed.still
        #     if @model.still
        #         console.log 'REMOVE'
        #         @.__removeFromGroup @__element
        #     else unless @changed.once
        #         console.log 'ADD'
        #         @.__addToGroup @__element
        if @changed.id
            @getDomElement().id = @model.id
        if @changed.width
            @getDomElement().style.width = @model.width
        if @changed.height
            @getDomElement().style.height = @model.height
        if @changed.clickable
            @getDomElement().style.pointerEvents = if @model.clickable then 'all' else 'none'
        
        if @changed.top or @changed.scalable or @changed.still
            obj = @getElement().obj
            if @model.still
                @root.topDomSceneStill.model.add obj
            else if not @model.scalable
                @root.topDomSceneNoScale.model.add obj
            else if @model.top
                @root.topDomScene.model.add obj
            else
                @root._scene.domModel.model.add obj
            @__forceUpdatePosition()

        console.log @__element.xform, @model, @changed
    # FIXME: This function is needed due to bug in basegl or THREE.js
    # which causes problems with positioning when layer changed
    __forceUpdatePosition: =>
        elem = @getElement()
        if elem?
            elem.position.y = if elem.position.y == 0 then 1 else 0
