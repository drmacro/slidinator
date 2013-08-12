package org.slidinator.slideset.datamodel;

import org.w3c.dom.Element;

/**
 * "Preformatted" content, where newlines are
 * significant. Normally set in a monospaced
 * font, such as Courier.
 *
 */
public class Preformatted extends SlideItem {

    public Preformatted(Element dataSourceElem) {
        super(dataSourceElem);
    }

}
