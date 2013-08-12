package org.slidinator.slideset;

import java.io.InputStream;

import org.slidinator.slideset.datamodel.SimpleSlideSet;


public interface SlideSetFactory {

    SimpleSlideSet
            constructSlideSet(
                    InputStream slideSetXmlUrl) throws Exception;

}