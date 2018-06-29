import * as Color     from 'basegl/display/Color'
import * as basegl    from 'basegl'

export white          = Color.rgb [1,1,1]
export bg             = (Color.hsl [40,0.08,0.09]).toRGB()
export selectionColor = bg.mix (Color.hsl [50, 1, 0.6]), 0.8
export nodeBg         = bg.mix white, 0.04


export valueTogglerColor = white

export transparent = Color.rgb [0, 0, 0, 0]
export activeArea = transparent
export hoverAspect = 0.7

export varHover = -> basegl.expr ->
    Color.rgb ['color_r', 'color_g', 'color_b']
        .mix white, 'hovered' * hoverAspect
