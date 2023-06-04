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
      --mtx_annotations                    Path to folder containing metatranscriptomic annotations from https://github.com/Chiamh/meta-omics-nf
      --mgx_annotations                    Path to folder containing metagenomic annotations from https://github.com/Chiamh/meta-omics-nf
      --mtx_protein_seqs                   For the annotate workflow only: Path to a folder containing all input protein sequences from metatranscriptomes (this will be recursively searched for *fa/*faa/*fasta files)
      --mgx_protein_seqs                   For the annotate workflow only: Path to a folder containing all input protein sequences from metagenomes (this will be recursively searched for *fa/*faa/*fasta files)
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



if (!params.mtx_annotations && !params.mtx_protein_seqs && params.process_rna){
    helpMessage()
    log.info"""
    [Error] The path to some inputs for MTX data is required because --process_rna is true
    """.stripIndent()
    exit 0
}

if (!params.mgx_annotations && !params.mgx_protein_seqs && params.process_dna){
    helpMessage()
    log.info"""
    [Error] The path to some inputs for MGX data is required because --process_dna is true
    """.stripIndent()
    exit 0
}

if (!params.microbeannotator_db){
    helpMessage()
    log.info"""
    [Error] --microbeannotator_db is required for calculating module completeness
    """.stripIndent()
    exit 0
}

/*
========================================================================================
    Define channels for inputs
========================================================================================
*/

if (params.process_rna && params.mtx_annotations){
    Channel.fromFilePairs( [params.mtx_annotations + '/**{_merged_panalign_annot.tsv,_merged_transl-search_annot.tsv}'], checkIfExists:true, size: 2 )
	.set{ ch_mtx_input }
}


if (params.process_dna && params.mgx_annotations){
    Channel.fromFilePairs( [params.mgx_annotations + '/**{_merged_panalign_annot.tsv,_merged_transl-search_annot.tsv}'], checkIfExists:true, size: 2 )
	.set{ ch_mgx_input }
}

/*
========================================================================================
    Include modules
========================================================================================
*/

include { EXTRACT_ANNOT_MGX } from '../modules/extract_and_annot_mgx.nf'
include { EXTRACT_ANNOT_MTX } from '../modules/extract_and_annot_mtx.nf'

/*
========================================================================================
    Workflow
========================================================================================
*/

//https://bioinformatics.stackexchange.com/questions/15739/use-conditional-in-workflow-in-nextflow-dsl2
//https://github.com/nextflow-io/patterns/blob/master/docs/conditional-process.adoc

// this is the main workflow
workflow FULL {
    if ( params.process_rna ){
	
		EXTRACT_ANNOT_MTX(params.microbeannotator_db,
						  params.pangene_seqs,
						  params.uniref90_seqs,
						  ch_mtx_input)
		
	}
    
    if ( params.process_dna ){
        
		EXTRACT_ANNOT_MGX(params.microbeannotator_db,
						  params.pangene_seqs,
						  params.uniref90_seqs,
						  ch_mgx_input)

}
}
