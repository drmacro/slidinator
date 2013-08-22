package org.slidinator.slideset;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;

import javax.xml.parsers.ParserConfigurationException;

import net.sf.saxon.s9api.Serializer;

import org.apache.commons.io.FileUtils;
import org.apache.poi.xslf.usermodel.XMLSlideShow;
import org.slidinator.slideset.visitors.PPTXGeneratingSlideSetVisitor;

/**
 * Slide Set transformer that generates PowerPoint (PPTX) output.
 * Requires the Apache POI library.
 *
 */
public class PPTXSlideSetTransformer
        extends SlideSetTransformerBase {

    private InputStream basePresentationStream;
    /**
     * Construct the transformer with the input map source and result output stream. 
     * @param mapSource Source providing the DITA map to process.
     * @param resultStream Stream to hold the primary result.
     * @param basePresentationStream Input stream providing the base PPTX deck to use as a template.
     * @throws ParserConfigurationException 
     */
    public PPTXSlideSetTransformer(
            InputStream mapStream,
            String mapSystemId,
            OutputStream resultStream,
            InputStream basePresentationStream) throws ParserConfigurationException {
        super(
                mapStream, 
                mapSystemId, 
                resultStream);
        this.basePresentationStream = basePresentationStream;
    }

    public PPTXSlideSetTransformer() throws ParserConfigurationException {
        super();
    }

    public PPTXSlideSetTransformer(
            File mapFile,
            InputStream basePresentationStream) throws Exception {
        super(new FileInputStream(mapFile),
                mapFile.toURI().toURL().toExternalForm());
        this.basePresentationStream = basePresentationStream;
    }

    @Override
    public
            void
            transform() throws Exception {
        ByteArrayOutputStream slideSetXmlOutStream = new ByteArrayOutputStream();
        Serializer  xsltResult = new Serializer();
        xsltResult.setOutputStream(slideSetXmlOutStream);
        
        log.info("Generating Slide Set XML from input DITA map...");
        // Transform the input DITA map into slide set XML
        generateSlideSetXml(xsltResult); // Needs to throw an exception if the transform fails.
        if (true || getDebug()) {
            File tempFile = File.createTempFile("SlideSetTransform-slideset-", ".xml");
            FileUtils.writeByteArrayToFile(tempFile, slideSetXmlOutStream.toByteArray());
            //System.out.println("Intermediate slide set XML written to: " + tempFile.getAbsolutePath());
            log.debug("Intermediate slide set XML written to: " + tempFile.getAbsolutePath());
        }
        

        log.info("Slide Set XML generated");
        
        // Now generate the PPTX:

        if (basePresentationStream == null) {
            throw new PPTXGenerationException("base PPTX presentation stream not set.");
        }
        
        log.info("Generating PowerPoint from slide set XML...");
        PPTXGeneratingSlideSetVisitor visitor = 
                new PPTXGeneratingSlideSetVisitor(
                        basePresentationStream);
        
        InputStream xmlInstream = new ByteArrayInputStream(slideSetXmlOutStream.toByteArray());
        visitor.generatePresentation(xmlInstream);
        XMLSlideShow pptx = visitor.getPptx();
        if (pptx == null) {
            throw new PPTXGenerationException("Failed to get a PPTX from the transform.");
        }
        pptx.write(getResultStream());
        log.info("Powerpoint Generated");
        
    }

    @Override
    public
            void
            setBasePresentation(
                    InputStream basePresentationStream) {
        this.basePresentationStream = basePresentationStream;
    }

}
