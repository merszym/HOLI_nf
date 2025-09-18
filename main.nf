// load the files

ch_split = Channel.fromPath("${params.split}/*.bam", checkIfExists:true) // input-data
ch_database = Channel.fromPath("${params.database}", checkIfExists:true) // bowtie-database
ch_names = Channel.fromPath("${params.names}", checkIfExists:true) // metaDMG-requirement
ch_nodes = Channel.fromPath("${params.nodes}", checkIfExists:true) // metaDMG-requirement
ch_acc2taxid = Channel.fromPath("${params.acc2taxid}", checkIfExists:true) // metaDMG-requirement

ch_versions = Channel.empty()

workflow {

// add a fake meta
ch_split.map{it -> [['sample': it.baseName, 'id':it.baseName], it] }.set{ ch_split }


//
// 0. BAM to Fasta
//



//
// 1. SGA preprocessing
//



//
// 2. Run Bowtie 2
//

// Run Bowtie

// Sort Bam-file for metaDMG


//
// 3. Run metaDMG
//





}
