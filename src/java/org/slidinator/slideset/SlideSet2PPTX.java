package org.slidinator.slideset;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.io.FilenameUtils;

/**
 * Command-line utility for generation of PPTX files from SlidesetML XML.
 * The input is a single simpleslideset XML document. The output is a 
 * PPTX file reflecting the slide content.
 *
 */
public class SlideSet2PPTX {

    /**
     * @param args
     */
    public static
            void main(
                    String[] args) {
        
        Options options = new Options();
        Option option;

        option = new Option("i", true, 
                "(Required) The path and filename of the simpleslideset document to process.");
        option.setArgName("slidesetFilePath");
        options.addOption(option);

        option = new Option("b", true, 
                "(Required) The path and filename of the PPTX file to use as the basis for the generated presentation.");
        option.setArgName("basePPTXPath");
        options.addOption(option);

        option = new Option("o", true, 
                "(optional) The output file. If an extension is not specified, the extension will be '.pptx'. " +
                "If not specified, the input file filename is used for the output, with the extension '.pptx'.");
        option.setArgName("basePPTXPath");
        options.addOption(option);

        option = new Option("otdir", true, 
                "(optional) The directory containing the DITA Open Toolkit to use (e.g., c:\\DITA-OT)." +
                " If not specified, uses the environment variable DITA_HOME.");
        option.setArgName("otdir");
        options.addOption(option);

        CommandLineParser parser = new BasicParser();
        CommandLine cmd = null;
        try {
            cmd = parser.parse(options, args);
        } catch (ParseException e) {
            System.err.println(e.getClass().getSimpleName() + " processing command-line arguments: " + e.getMessage());
            System.exit(-1);
        }
        if (!cmd.hasOption("i") || !cmd.hasOption("b")) {
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp("SlideSet2PPTX", options);
            System.exit(-1);
        }
        String slidesetPath = cmd.getOptionValue("i");
        System.out.println("+ [INFO] Input file: " + slidesetPath);
        String basePPTXPath = cmd.getOptionValue("b");
        System.out.println("+ [INFO] Base PPTX: " + basePPTXPath);
        String resultPPTXPath = null;
        if (cmd.hasOption("o")) {
            resultPPTXPath = cmd.getOptionValue("o");            
            System.out.println("+ [INFO] -o (ouptut file): " + resultPPTXPath);
        }
        String otPath = null;
        if (cmd.hasOption("otdir")) {
            otPath = cmd.getOptionValue("otdir");            
            System.out.println("+ [INFO] Open Toolkit directory: " + otPath);
        }
        
        String ditaHomePath = otPath;
        if (otPath == null) {
            otPath = System.getenv("DITA_HOME");
            if (ditaHomePath == null || "".equals(ditaHomePath.trim())) {
                System.err.println("Environment variable DITA_HOME not set and -otdir parameter not specified, cannot continue.");
                System.exit(-1);
            }
            System.out.println("+ [INFO] Open Toolkit directory: " + otPath);
            
        }
        
        // Now validate the arguments:
        String userDirStr = System.getProperty("user.dir");
        File userDir = new File(userDirStr);

        File slidesetFile = new File(slidesetPath);
        if (!slidesetFile.isAbsolute()) {
            slidesetFile = new File(userDir, slidesetFile.getPath());
        }
        if (!slidesetFile.exists()) {
            System.err.println("Cannot find slideset file \"" + slidesetFile.getAbsolutePath() + "\"");
            System.exit(-1);
        }
        if (!slidesetFile.canRead()) {
            System.err.println("Cannot read slideset file \"" + slidesetFile.getAbsolutePath() + "\"");
            System.exit(-1);
        }
        if (slidesetFile.isDirectory()) {
            System.err.println("Slideset file \"" + slidesetFile.getAbsolutePath() + "\" is a directory");
            System.exit(-1);
        }

        File basePPTXFile = new File(basePPTXPath);
        if (!basePPTXFile.isAbsolute()) {
            basePPTXFile = new File(userDir, basePPTXFile.getPath());
        }
        if (!basePPTXFile.exists()) {
            System.err.println("Cannot find base PPTX file \"" + basePPTXFile.getAbsolutePath() + "\"");
            System.exit(-1);
        }
        if (!basePPTXFile.canRead()) {
            System.err.println("Cannot read base PPTX file \"" + basePPTXFile.getAbsolutePath() + "\"");
            System.exit(-1);
        }
        if (basePPTXFile.isDirectory()) {
            System.err.println("Base PPTX file \"" + slidesetFile.getAbsolutePath() + "\" is a directory");
            System.exit(-1);
        }
        
        File resultPPTXFile = null;
        if (resultPPTXPath == null) {
            File resultPPTXDir = slidesetFile.getParentFile();
            resultPPTXFile = 
                    new File(
                            resultPPTXDir, 
                            FilenameUtils.getBaseName(slidesetFile.getName()) + ".pptx");
            System.out.println("+ [INFO] Result PPTX file: " + resultPPTXFile.getAbsolutePath());
        } else {
            resultPPTXFile = new File(resultPPTXPath);
            if (!resultPPTXFile.isAbsolute()) {
                resultPPTXFile = new File(userDir, resultPPTXFile.getPath());
            }
            if (resultPPTXFile.getName().endsWith(".pptx")) {
            	resultPPTXFile.getParentFile().mkdirs();
            } else {
            	resultPPTXFile.mkdirs();
            }
            if (resultPPTXFile.isDirectory()) {
            	System.out.println("+ [INFO] " + resultPPTXFile.getAbsolutePath() + " is a directory.");
                resultPPTXFile = 
                        new File(
                                resultPPTXFile, 
                                FilenameUtils.getBaseName(slidesetFile.getName()) + ".pptx");                
                System.out.println("+ [INFO] Result PPTX file: " + resultPPTXFile.getAbsolutePath());
            }
        }
        if (!basePPTXFile.canWrite()) {
            System.err.println("Do not have write permission for base PPTX file \"" + basePPTXFile.getAbsolutePath() + "\"");
            System.exit(-1);
        }
        
        basePPTXFile.getParentFile().mkdirs();
        if (!basePPTXFile.getParentFile().exists()) {
            System.err.println("Was unable to create output directory \"" + basePPTXFile.getParent() + "\"");
            System.exit(-1);
        }
        
        File ditaHomeDir = new File(ditaHomePath);
        if (!ditaHomeDir.exists()) {
            System.err.println("DITA Open Toolkit directory (from DITA_HOME environment variable) \"" + ditaHomeDir.getAbsolutePath() + "\" does not exist.");
            System.exit(-1);
        }

        
        System.out.println("+ [INFO] SlideSet2PPTX: Processing slide set: \"" + slidesetFile.getAbsolutePath() + "\".");
        System.out.println("+ [INFO] SlideSet2PPTX: Using base PPTX file: \"" + basePPTXFile.getAbsolutePath() + "\".");
        System.out.println("+ [INFO] SlideSet2PPTX: To result PPTX file:  \"" + resultPPTXFile.getAbsolutePath() + "\".");
        System.out.println("+ [INFO] SlideSet2PPTX: Using Open Toolkit:   \"" + ditaHomePath + "\".");
        
        try {
            doPPTXGeneration(
                    slidesetFile, 
                    basePPTXFile, 
                    resultPPTXFile, 
                    ditaHomeDir);
            System.out.println(" + [INFO] Done.");
        } catch (Exception e) {
            System.err.println(e.getClass().getSimpleName() + " generating PPTX: " + e.getMessage());
            e.printStackTrace(System.err);
            System.exit(-1);
        }

    }

    private static
            void
            doPPTXGeneration(
                    File slidesetFile,
                    File basePPTXFile,
                    File resultPPTXFile,
                    File ditaOtDir) throws Exception {
        
        InputStream basePresentationStream = new FileInputStream(basePPTXFile);

        PPTXSlideSetTransformer transformer = 
                new PPTXSlideSetTransformer(
                        slidesetFile,                         
                        basePresentationStream);
        transformer.setResultStream(new FileOutputStream(resultPPTXFile));
        transformer.generatePPTXFromSlideSetXML(new FileInputStream(slidesetFile));
        System.out.println(" + [INFO] PPTX file written to \"" + resultPPTXFile.getAbsolutePath());
        
        
    }

}
