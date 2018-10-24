import {Background}       from 'shape/node/Background'
import {Widget}           from 'widget/Widget'
import {EditableText}        from 'view/EditableText'


export class Expression extends Widget
    initModel: =>
        model = super()
        model.expression = ''
        model

    prepare: =>
        @addDef 'expression', EditableText,
            entries: []
            kind:    EditableText.EXPRESSION
        @addDef 'background', Background,
            width: @style.node_bodyWidth

    update: =>
        if @changed.expression
            @updateDef 'expression',
                text:    @model.expression
                color:    [@style.text_color_r, @style.text_color_g, @style.text_color_b]
                # frameColor:
                #     [ @style.port_borderColor_h, @style.port_borderColor_s
                #     , @style.port_borderColor_l, @style.port_borderColor_a
                #     ]

            @__minHeight = @def('expression').height() + 2*@style.node_widgetOffset_v

            @updateDef 'background', height: @__minHeight
        if @changed.siblings
            @updateDef 'background',
                roundBottom: not @model.siblings.bottom
                roundTop:    not @model.siblings.top
    # adjustSrc: (view) =>
    #     view.position.xy = [@style.node_bodyWidth/2, 2 * @style.node_radius + @style.node_headerOffset]
    #     @view('widgets').scale.xy = [0,0]
    #     @view('background').scale.xy = [0,0]
    #     # @setPosition view, [@style.node_widgetOffset_h, 0]
    #     # @setPosition view, [0, 100]
    # adjustDst: (view) =>
    #     @setPosition view, [@style.node_bodyWidth/2, 2 * @style.node_radius + @style.node_headerOffset]
    #     @setScale @view('widgets'), [0,0]
    #     @setScale @view('background'), [0, 0]

    adjust: (view) =>
        if @changed.once
            # @setPosition view, [0, 0]
            # @setScale @view('widgets'), [1, 1]
            # @setScale @view('background'), [1, 1]
            @view('expression').position.xy = [@style.node_bodyWidth/2, - @__minHeight/2]
