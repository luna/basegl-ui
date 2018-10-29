import {BasicComponent} from 'abstract/BasicComponent'
import * as basegl      from 'basegl'


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
        cssClassName: []

    redefineRequired: => @changed.element

    define: =>
        @html = document.createElement @model.element
        basegl.symbol @html

    adjust: =>
        domElem = @getDomElement()
        return unless domElem?

        if @changed.id
            if @model.id?
                domElem.id = @model.id
            else
                delete domElem.id
        if @changed.width
            domElem.style.width = @model.width
        if @changed.height
            domElem.style.height = @model.height
        if @changed.clickable
            domElem.style.pointerEvents = if @model.clickable then 'all' else 'none'
        if @changed.cssClassName
            domElem.className = @model.cssClassName

        if @changed.top or @changed.scalable or @changed.still
            obj = domElem.obj
            if @model.still
                @root.topDomSceneStill.model.add obj
            else if not @model.scalable
                @root.topDomSceneNoScale.model.add obj
            else if @model.top
                @root.topDomScene.model.add obj
            else
                @root.scene.domModel.model.add obj
            @__forceUpdatePosition()

    # FIXME: This function is needed due to bug in basegl or THREE.js
    # which causes problems with positioning when layer changed
    __forceUpdatePosition: =>
        elem = @getElement()
        if elem?
            elem.position.y = if elem.position.y == 0 then 1 else 0


export class HtmlShapeWithScene extends HtmlShape
    define: =>
        @dom    = document.createElement @model.element
        @camera = @root.getCamera()
        @stillCamera = @root.topDomSceneStill.camera
        @sceneId = @model.id
        @withScene (scene) => scene.addDomModelWithNewCamera(@sceneId, @camera) 
        basegl.symbol @dom

    adjust: =>
        if @scene? and (not @addedToScene)
            @scene.model.add @getElement().obj
            @addedToScene = true

    makeStill: =>
        @scene._camera = @stillCamera
    
    makeMovable: =>
        @scene._camera = @camera