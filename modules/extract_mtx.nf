// extract protein sequences based on metatranscriptome annotations and pathway analysis with microbeannotator (full workflow)

process EXTRACT_MTX {
	label "process_medium"
	tag "${sample_id}"
	publishDir "${params.outdir}/RNA", mode: 'copy'
	
	input:
	path pangene_seqs
	path uniref90_seqs
	tuple val(sample_id), path(annots_file)
	
	output:
	tuple val(sample_id), path("${sample_id}_mtx_proteins.fa"), emit: seqs
	
	when:
	params.process_rna
	
	script:
	"""
	
	extract_and_annot_helper.sh "${sample_id}"
	
	filterbyname.sh in=${uniref90_seqs} out=${sample_id}_merged_uniref90_hits.fa names=${sample_id}_merged_uniref90_IDs ignorejunk=t include=t
	
	filterbyname.sh in=${pangene_seqs} out=${sample_id}_merged_pangene_hits.fa names=${sample_id}_merged_pangene_IDs ignorejunk=t include=t
	
	cat ${sample_id}_merged_pangene_hits.fa ${sample_id}_merged_uniref90_hits.fa > ${sample_id}_mtx_proteins.fa

		
	"""
}

