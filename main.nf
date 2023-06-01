#!/usr/bin/env nextflow

/*
========================================================================================
    Microbeannotator for metagenomics: Nextflow pipeline
========================================================================================
    Github : https://github.com/Chiamh/meta-microbeannotator-nf
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl=2

/*
========================================================================================
    Help messages and warnings
========================================================================================
*/

//https://www.baeldung.com/groovy-def-keyword
//https://www.nextflow.io/blog/2020/cli-docs-release.html

def helpMessage() {
  // adapted from nf-core
    log.info"""
    
  Usage for main workflow:
    The typical command for running the main workflow for the pipeline is as follows:
      nextflow run main.nf
	  --mtx_annotations PATH TO FOLDER FOR ANNOTATIONS_FOR_RNA
	  --mgx_annotations PATH TO FOLDER FOR ANNOTATIONS_FOR_DNA

  Usage for annotate workflow:
    The typical command for running the annotate only (no sequence extraction) workflow for the pipeline is as follows:
	  --mtx_protein_seqs PATH TO FOLDER FOR MTX_PROTEIN_FASTAS
      --mgx_protein_seqs PATH TO FOLDER FOR MGX_PROTEIN_FASTAS
    
	NOTE: A more user-friendly approach is to specify these parameters in a *.config file under a custom profile 
	
    IMPT: Set either the --process_rna or --process_dna arguments to false if no RNA or DNA INPUTS are provided, respsectively. 
           
    Input and database arguments are null by default.
    Rather than manually specifying the paths to the databases, it is best to create a custom nextflow config file.
     
    Input arguments:
      --mtx_annotations                    Path to metatranscriptomic annotations from https://github.com/Chiamh/meta-omics-nf
	  --mgx_annotations                    Path to metagenomic annotations from https://github.com/Chiamh/meta-omics-nf
	  --mtx_protein_seqs                   Path to a folder containing all input protein sequences from metatranscriptomes (this will be recursively searched for *fa/*faa/*fasta files)
      --mgx_protein_seqs                   Path to a folder containing all input protein sequences from metagenomes (this will be recursively searched for *fa/*faa/*fasta files)
    Database arguments:
      --pangene_seqs                Path to the folder with protein sequences from pangenomes of choice
      --uniref_seqs			        Path to the folder with protein sequences from Uniref90
	  --microbeannotator_db			Path to the folder with the microbeannotator database
    Workflow options:
      --process_rna                 Turns on steps to process metatranscriptomes [Default: true].
      --process_dna                 Turns on steps to process metagenomes [Default: true].
    Output arguments:
      --outdir                      The output directory where the results will be saved [Default: ./pipeline_results]
      --tracedir                    The directory where nextflow logs will be saved [Default: ./pipeline_results/pipeline_info]
    AWSBatch arguments:
      --awsregion                   The AWS Region for your AWS Batch job to run on [Default: false]
      --awsqueue                    The AWS queue for your AWS Batch job to run on [Default: false]
    Others:
      --help		            Display this help message
    """
}

if (params.help){
    helpMessage()
    exit 0
}


/*
========================================================================================
    Include modules
========================================================================================
*/

include { FULL } from './workflows/full_workflow.nf'
include { ANNOTATE } from './workflows/annotate.nf'

/*
========================================================================================
    Main workflow (default)
========================================================================================
*/

// this is the main workflow
workflow {
    
    FULL ()
     
}

// Use the annotate workflow to use microbeannotator as a standalone to annotate protein fasta files.
workflow annotate {

    ANNOTATE ()
}