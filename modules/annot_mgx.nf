// Pathway analysis with microbeannotator 

process ANNOT_MGX {
	label "process_medium"
	tag "${sample_id}"
	publishDir "${params.outdir}/DNA", mode: 'copy'
	
	input:
	path microbeannotator_db
	tuple val(sample_id), path(fasta_file)
	
	output:
	tuple val(sample_id), path("${sample_id}_microbeannotator_out"), emit: results_folder
	tuple val(sample_id), path("${sample_id}_metabolic_summary_module_completeness.tab"), emit: annotations
	
	when:
	params.process_dna
	
	script:
	"""
		
	microbeannotator -i ${fasta_file[0]} -d ${microbeannotator_db} -o ${sample_id}_microbeannotator_out -m diamond -t $task.cpus --light
	
	if [ -f ${sample_id}_microbeannotator_out/metabolic_summary__module_completeness.tab ]; then
        cp ${sample_id}_microbeannotator_out/metabolic_summary__module_completeness.tab "${sample_id}_metabolic_summary_module_completeness.tab"
    fi
		
	"""
}

