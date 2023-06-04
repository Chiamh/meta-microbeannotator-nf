#!/bin/bash
set -e
set -u

sample_id=${1}

awk '(NR>1){print $1}' "${sample_id}"_merged_panalign_annot.tsv > "${sample_id}"_merged_pangene_IDs
	
awk -F "\t" '(NR>1){print $5}' "${sample_id}"_merged_transl-search_annot.tsv > "${sample_id}"_merged_uniref90_IDs