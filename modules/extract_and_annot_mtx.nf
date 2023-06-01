// extract protein sequences based on metatranscriptome annotations and pathway analysis with microbeannotator (full workflow)

process EXTRACT_ANNOT_MTX {
	label "process_medium"
	tag "${sample_id}"
	publishDir "${params.outdir}/RNA", mode: 'copy'
	
	input:
	path microbeannotator_db
	path pangene_seqs
	path uniref90_seqs
	tuple val(sample_id), path(annots_file)
	
	output:
	tuple val(sample_id), path("${sample_id}_mtx_proteins.fa"), emit: seqs
	tuple val(sample_id), path("${sample_id}_microbeannotator_out"), emit: results_folder
	tuple val(sample_id), path("${sample_id}_metabolic_summary_module_completeness.tab"), emit: annotations
	
	when:
	params.process_rna
	
	script:
	"""
	
	awk '(NR>1){print $1}' "${sample_id}_merged_panalign_annot.tsv" > "${sample_id}_merged_pangene_IDs"
	
	awk -F "\t" '(NR>1){print $5}' "${sample_id}_merged_transl-search_annot.tsv" > "${sample_id}_merged_uniref90_IDs"
	
	filterbyname.sh in=${uniref90_seqs} out=${sample_id}_merged_uniref90_hits.fa names=${sample_id}_merged_uniref90_IDs ignorejunk=t include=t
	
	filterbyname.sh in=${pangene_seqs} out=${sample_id}_merged_pangene_hits.fa names=${sample_id}_merged_pangene_IDs ignorejunk=t include=t
	
	cat ${sample_id}_merged_pangene_hits.fa ${sample_id}_merged_uniref90_hits.fa > ${sample_id}_mtx_proteins.fa
	
	microbeannotator -i ${sample_id}_mtx_proteins.fa -d ${microbeannotator_db} -o ${sample_id}_microbeannotator_out -m diamond -t $task.cpus --light
	
	if [ -f ${sample_id}_microbeannotator_out/metabolic_summary__module_completeness.tab ]; then
        cp ${sample_id}_microbeannotator_out/metabolic_summary__module_completeness.tab "${sample_id}_metabolic_summary_module_completeness.tab"
    fi
		
	"""
}

