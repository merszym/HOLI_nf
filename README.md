# HOLI pipeline

For a comparison of [quicksand](www.github.com/mpieva/quicksand) with HOLI (Pedersen et al. 2016), we implemented this HOLI pipeline to handle the processing of multiple BAM files in parallel and to create a quicksand-like summary report.

This implementation of the HOLI principles follows the KapCopenhagen-analysis described in Kjær et al. 2022. The only difference is the metaDMG step that we implemented according to https://github.com/miwipe/Holi. 

In summary, our implementation of HOLI converts input BAM files to FASTQ, which then undergo three different preprocessing steps with sga (preprocess, index and filter). The filtered FASTQ files are then mapped with bowtie2 to the provided inxed, followed by sorting of the alignments with samtools and metaDMG-cpp analysis (lca, dfit and aggregate).

### Requirements
- Nextflow v22.10 (or larger)
- Singularity

### Bowtie Index and NCBI Files

The pipeline requires a (single) bowtie2-index for classification, as well as NCBI taxonomy files for the metaDMG-step. As input for the flag, provide the folder containing the bt2-files.
- see [here](https://www.metagenomics.wiki/tools/bowtie2/index) for an example of how to create such a bowtie2-index

The NCBI taxonomy files required by metaDMG are `names.dmp`, `nodes.dmp`, and `accession2taxid`

- [Names and Nodes (taxdump)](https://ftp.ncbi.nih.gov/pub/taxonomy/new_taxdump/)
- [Accession2taxid](https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz) 

### Run the pipeline

Following the creation of the bowtie-2 index and the download of the NCBI-files, run the pipeline with the following command:

```
nextflow run merszym/HOLI_nf \
	--split INPUT \
	--database BOWTIE-INDEX 
	--names names.dmp \
	--nodes nodes.dmp \
	--acc2tax nucl_gb.accession2taxid \
	-profile singularity
```

### Post-pipeline filters
Post-processing has to be performed by the user!

For the quicksand-benchmarking, the post-processing of the output follows Kjær et al. 2022 (https://github.com/miwipe/KapCopenhagen/blob/main/scripts/KapKmetaDMG6AnimalFamilies.R):
- initial filtering to assignments with 5 or more sequences and restricted assignments to the ‘family’ rank. 
- “half of the median” filter, keeping only families with more assigned sequences than half the median of all family sequences
- only keep families that reached a minimum percentage abundance of 1% (remaining families).
