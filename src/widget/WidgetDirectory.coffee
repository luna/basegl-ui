import {ContinousSlider, DiscreteSlider} from 'widget/Slider'
import {Checkbox}                        from 'widget/Checkbox'
import {TextInput}                       from 'widget/TextInput'
import {Widget}                          from 'widget/Widget'

widgetMap =
    'Bool' : Checkbox
    'Int'  : DiscreteSlider
    'Real' : ContinousSlider
    'Text' : TextInput

export lookupWidget = (widget) =>
    widget.cons or widgetMap[widget.cls] or Widget
