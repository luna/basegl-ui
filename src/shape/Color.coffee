import * as Color     from 'basegl/display/Color'

export white          = Color.rgb [1,1,1]
export bg             = (Color.hsl [40,0.08,0.09]).toRGB()
export selectionColor = bg.mix (Color.hsl [50, 1, 0.6]), 0.8
export nodeBg         = bg.mix white, 0.04


export valueTogglerColor = white

export transparent = Color.rgb [0, 0, 0, 0]
export activeArea = transparent
