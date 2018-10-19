import * as Color     from 'basegl/display/Color'
import * as basegl    from 'basegl'

export white          = Color.rgb [1,1,1]
export base           = (style) -> basegl.expr ->
    Color.rgb [style.baseColor_r, style.baseColor_g, style.baseColor_b]
export bg             = (style) -> basegl.expr ->
    Color.hsl([style.bgColor_h, style.bgColor_s, style.bgColor_l]).toRGB()
export selectionColor = (style) -> basegl.expr ->
    bg(style).mix (Color.hsl [style.node_selection_h, style.node_selection_s, style.node_selection_l]), style.node_selection_a
export nodeBg         = (style) -> basegl.expr ->
    bg(style).mix base(style), style.node_opacity

export valueTogglerColor = white
export visualizationMenu = valueTogglerColor

export transparent = Color.rgb [0, 0, 0, 0]
export activeArea = transparent

export varHover = (style) -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b']
        .mix base(style), 'hovered' * style.hoverAspect

export varAlpha = (style) -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b', 'color_a']

export varHSLAlpha = (style) -> basegl.expr ->
    Color.hsl ['color_h', 'color_s', 'color_l', 'color_a']

export varAlphaHover = (style) -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b', 'color_a']
        .mix base(style), 'hovered' * style.hoverAspect

export sliderColor   = (style) -> basegl.expr ->
    bg(style).mix base(style), style.sliderFront
export sliderBgColor = (style) -> basegl.expr ->
    bg(style).mix base(style), style.sliderBg
export activeGreen = (style) -> basegl.expr ->
    Color.rgb [style.colorActiveGreen_r, style.colorActiveGreen_g, style.colorActiveGreen_b, style.colorActiveGreen_a]

export placeholder = [1, 0, 0]
