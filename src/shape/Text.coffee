import * as basegl from 'basegl'
import {BasicComponent}  from 'abstract/BasicComponent'
import {ContainerComponent}  from 'abstract/ContainerComponent'
import * as color from 'shape/Color'
import * as Color     from 'basegl/display/Color'

export class TextShape extends BasicComponent
    initModel: =>
        text: ''
        align: 'center'
        color: null
        size: null

    redefineRequired: =>
        @changed.text or @changed.size or @changed.color

    define: =>
        @__createText
            str: @model.text
            color: Color.rgb @model.color if @model.color?
            size: @model.size

    adjust: (element) =>
        size = @size()
        element.position.x =
            if @model.align == 'center'
                -size[0] / 2
            else if @model.align == 'right'
                -size[0]
            else
                0
        element.position.y = - size[1]/2

    size:   => @__getTextSize   @__element
    width:  => @__getTextWidth  @__element
    height: => @__getTextHeight @__element

    __getTextWidth: (textGroup) =>
        textMinX = undefined
        textMaxX = undefined
        textGroup.children.forEach (child) =>
            l = child.position.x
            r = child.position.x + child.bbox.x
            textMinX = l unless l > textMinX
            textMaxX = r unless r < textMaxX
        (textMaxX - textMinX) or 0


    __getTextHeight: (textGroup) =>
        textMinY = undefined
        textMaxY = undefined
        textGroup.children.forEach (child) =>
            b = child.position.y
            t = child.position.y + child.bbox.y
            textMinY = b unless b > textMinY
            textMaxY = t unless t < textMaxY
        (textMaxY - textMinY) or 0

    __getTextSize: (textGroup) =>
        textMinX = undefined
        textMaxX = undefined
        textMinY = undefined
        textMaxY = undefined
        textGroup.children.forEach (child) =>
            l = child.position.x
            r = child.position.x + child.bbox.x
            textMinX = l unless l > textMinX
            textMaxX = r unless r < textMaxX
            b = child.position.y
            t = child.position.y + child.bbox.y
            textMinY = b unless b > textMinY
            textMaxY = t unless t < textMaxY
        [(textMaxX - textMinX) or 0, (textMaxY - textMinY) or 0]

    __createText: (attrs) =>
        addToScene: (scene) =>
            attrs.scene = scene
            attrs.str        ?= ''
            attrs.fontFamily ?= 'SourceCodePro'
            attrs.size       ?= @style.text_size
            basegl.text attrs
