package org.slidinator.slideset;

import java.util.Stack;

import javax.xml.transform.SourceLocator;
import javax.xml.transform.TransformerException;

import net.sf.saxon.event.MessageEmitter;
import net.sf.saxon.event.PipelineConfiguration;
import net.sf.saxon.om.NamePool;
import net.sf.saxon.s9api.MessageListener;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.trans.XPathException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 *
 */
public class SaxonMessageListener implements MessageListener {

	private Stack<String> elemStack = new Stack<String>();
	private NamePool namePool;
	protected MessageEmitter emitter;
	private Log myLog = LogFactory.getLog(SaxonMessageListener.class);
	private Log log;

	/**
	 * 
	 */
	public SaxonMessageListener() {
		super();
		this.log = myLog;
	}

	public SaxonMessageListener(Log log) {
		this.log = log;
	}

	public void attribute(int arg0, int arg1, CharSequence arg2,
			int arg3, int arg4) throws XPathException {		
				
			}

	public void close() throws XPathException {
		// Nothing to do
	}

	public void comment(CharSequence arg0, int arg1, int arg2)
			throws XPathException {
				
			}

	public void endDocument() throws XPathException {
		// Nothing to do
	}

	public void endElement() throws XPathException {
	
	}

	public void namespace(int arg0, int arg1) throws XPathException {
		
	}

	public void open() throws XPathException {
		
	}

	public void processingInstruction(String arg0, CharSequence arg1, int arg2,
			int arg3) throws XPathException {
				
			}

	public void startContent() throws XPathException {
		
	}

	public void startDocument(int arg0) throws XPathException {
	}

	public void startElement(int nameCode, int arg1, int arg2,
			int arg3) throws XPathException {
				String tagName = this.namePool.getDisplayName(nameCode);
				this.elemStack.push(tagName);
			}

	public void reportExceptionToLog(TransformerException e, String msg) {
		log.error(msg, e);
	}
	
	public void error(TransformerException e) throws TransformerException {
		reportExceptionToLog(e, " - ERROR: ");
	}

	public void fatalError(TransformerException e) throws TransformerException {
		reportExceptionToLog(e, " - FATAL: ");
		e.printStackTrace();
	}

	public PipelineConfiguration getPipelineConfiguration() {
		return this.emitter.getPipelineConfiguration();
	}

	public void setPipelineConfiguration(PipelineConfiguration arg0) {
		this.emitter.setPipelineConfiguration(arg0);
		
	}

	public void setSystemId(String arg0) {
		this.emitter.setSystemId(arg0);
	}

	public void setUnparsedEntity(String arg0, String arg1, String arg2)
			throws XPathException {
				this.emitter.setUnparsedEntity(arg0, arg1, arg2);
			}

	public String getSystemId() {
		return this.emitter.getSystemId();
	}

	public String formatXdmNodeMessage(XdmNode msg, SourceLocator srcLoc) {
		String locStr = formatLocString(srcLoc);
		String logMsg = locStr + msg.getStringValue();
		return logMsg;
	}

	public String formatLocString(SourceLocator srcLoc) {
		long lineNum = srcLoc.getLineNumber();
		int colNum = srcLoc.getColumnNumber();
	
		String locStr = "";
		if (lineNum > 0 && colNum >= 0) {
			locStr = "Line " + lineNum + ":" + colNum + " - ";
		}
		return locStr;
	}

	@Override
	public void message(XdmNode msg, boolean terminate, SourceLocator srcLoc) {
		String logMsg = formatXdmNodeMessage(msg, srcLoc);
		if (terminate) {
			log.error(logMsg);
		} else {
			log.info(logMsg);
		}
		
	}

}