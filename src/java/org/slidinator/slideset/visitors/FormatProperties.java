package org.slidinator.slideset.visitors;

import java.awt.Color;
import java.util.HashMap;
import java.util.Map;

/**
 * Holds a set of formatting properties that can
 * be set on a RichTextRun
 *
 */
public class FormatProperties {

    private Map<String, Object> props = new HashMap<String, Object>();

    public
            String getFontFamily() {
        return (String)props.get("fontfamily");
    }

    public
            int getFontSize() {
        Integer i = (Integer)props.get("fontsize");
        if (i != null) 
            return i.intValue();
        return -1;
    }

    public
            Color getFontColor() {
        return (Color)props.get("fontcolor");
    }

    public
            void setFontFamily(
                    String string) {
        props.put("fontfamily", string);
    }

}
