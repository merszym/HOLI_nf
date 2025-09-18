// load the files

ch_split     = Channel.fromPath("${params.split}/*"       ,checkIfExists:true) // input-data
ch_database  = Channel.fromPath("${params.database}/*bt2" ,checkIfExists:true) // bowtie-database
ch_names     = Channel.fromPath("${params.names}"         ,checkIfExists:true) // metaDMG-requirement
ch_nodes     = Channel.fromPath("${params.nodes}"         ,checkIfExists:true) // metaDMG-requirement
ch_acc2taxid = Channel.fromPath("${params.acc2tax}"       ,checkIfExists:true) // metaDMG-requirement

ch_versions = Channel.empty()

workflow {

// add a first meta
ch_split.map{it -> [['sample': it.baseName, 'id':it.baseName], it] }.view().set{ ch_split }


//
// 0. BAM to Fastq
//

//input BAMS need to be converted to fastq-files

//
// 1. SGA preprocessing
//

// 1.1 SGA preprocess

// 1.2 SGA index

// 1.3 SGA filter

//
// 2. Run Bowtie 2
//

ch_database.map{it -> [it.baseName.split('\\.')[0], it]}.groupTuple().set{ch_bowtie2}

// Run Bowtie --> SAM-file output


// Sort SAM-file for metaDMG by name


//
// 3. Run metaDMG-cpp
//

// 3.1 metaDMG-cpp lca

// 3.2 metaDMG-cpp dfit

// 3.3 metaDMG-cpp aggregate

//
// 4. Report summary
//

// use the aggregate-table as base, add RG and Database used

}
