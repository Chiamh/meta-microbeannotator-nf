// extract protein sequences based on metagenomic annotations and pathway analysis with microbeannotator (full workflow)

process EXTRACT_ANNOT_MGX {
	label "process_medium"
	tag "${sample_id}"
	publishDir "${params.outdir}/DNA", mode: 'copy'
	
	input:
	path microbeannotator_db
	path pangene_seqs
	path uniref90_seqs
	tuple val(sample_id), path(annots_file)
	
	output:
	tuple val(sample_id), path("${sample_id}_mgx_proteins.fa"), emit: seqs
	tuple val(sample_id), path("${sample_id}_microbeannotator_out"), emit: results_folder
	tuple val(sample_id), path("${sample_id}_metabolic_summary_module_completeness.tab"), emit: annotations
	
	when:
	params.process_dna
	
	script:
	"""
	extract_and_annot_helper.sh "${sample_id}"
	
	filterbyname.sh in=${uniref90_seqs} out=${sample_id}_merged_uniref90_hits.fa names=${sample_id}_merged_uniref90_IDs ignorejunk=t include=t
	
	filterbyname.sh in=${pangene_seqs} out=${sample_id}_merged_pangene_hits.fa names=${sample_id}_merged_pangene_IDs ignorejunk=t include=t
	
	cat ${sample_id}_merged_pangene_hits.fa ${sample_id}_merged_uniref90_hits.fa > ${sample_id}_mgx_proteins.fa
	
	microbeannotator -i ${sample_id}_mgx_proteins.fa -d ${microbeannotator_db} -o ${sample_id}_microbeannotator_out -m diamond -t $task.cpus --light
	
	if [ -f ${sample_id}_microbeannotator_out/metabolic_summary__module_completeness.tab ]; then
        cp ${sample_id}_microbeannotator_out/metabolic_summary__module_completeness.tab "${sample_id}_metabolic_summary_module_completeness.tab"
    fi
		
	"""
}

