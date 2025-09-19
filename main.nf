// Import modules

include { SAMTOOLS_FASTQ } from './modules/local/samtools_fastq'
include { SAMTOOLS_SORT  } from './modules/local/samtools_sort'
include { SGA_PREPROCESS } from './modules/local/sga_preprocess'
include { BOWTIE2        } from './modules/local/bowtie2'
include { METADMG_CPP    } from './modules/local/metadmg-cpp'

// load the files

ch_split     = Channel.fromPath("${params.split}/*"       ,checkIfExists:true) // input-data
ch_database  = Channel.fromPath("${params.database}/*bt2" ,checkIfExists:true) // bowtie-database
ch_names     = Channel.fromPath("${params.names}"         ,checkIfExists:true) // metaDMG-requirement
ch_nodes     = Channel.fromPath("${params.nodes}"         ,checkIfExists:true) // metaDMG-requirement
ch_acc2taxid = Channel.fromPath("${params.acc2tax}"       ,checkIfExists:true) // metaDMG-requirement

ch_versions = Channel.empty()

// some required functions
def has_ending(file, extension){
    return extension.any{ file.toString().toLowerCase().endsWith(it) }
}

workflow {

// add a first meta
ch_split.map{it -> [['sample': it.baseName, 'id':it.baseName], it] }.set{ ch_split }

//split input into bam- and fastq-files
ch_split.branch {
    bam: it[1].getExtension() == 'bam' //input BAMS need to be converted to fastq-files
    fastq: has_ending( it[1], ["fastq","fastq.gz","fq","fq.gz"])
    fail: true
}
.set{ ch_split }

//
// 0. BAM to Fastq
//

SAMTOOLS_FASTQ(ch_split.bam)

ch_versions = ch_versions.mix(SAMTOOLS_FASTQ.out.versions.first())
ch_converted_fastq = SAMTOOLS_FASTQ.out.fastq

ch_split_fastq = ch_split.fastq.mix(ch_converted_fastq)

//
// 1. SGA preprocessing -> I put it all in one module now...
//

// 1.1 SGA preprocess
// 1.2 SGA index
// 1.3 SGA filter

SGA_PREPROCESS(ch_split_fastq)
ch_versions = ch_versions.mix(SGA_PREPROCESS.out.versions.first())

ch_fastq_uniq = SGA_PREPROCESS.out.fastq


//
// 2. Run Bowtie 2
//

ch_database.map{it -> [it.baseName.split('\\.')[0], it]}.groupTuple().set{ch_bowtie2}

ch_for_bowtie = ch_fastq_uniq.combine(ch_bowtie2)

// Run Bowtie --> SAM-file output
BOWTIE2(ch_for_bowtie)
ch_versions = ch_versions.mix(BOWTIE2.out.versions.first())

ch_sam = BOWTIE2.out.sam

// Sort SAM-file for metaDMG by name

SAMTOOLS_SORT(ch_sam)
ch_versions = ch_versions.mix(SAMTOOLS_SORT.out.versions.first())

ch_bam = SAMTOOLS_SORT.out.bam

//
// 3. Run metaDMG-cpp --> Put it all in one module
//

// 3.1 metaDMG-cpp lca
// 3.2 metaDMG-cpp dfit
// 3.3 metaDMG-cpp aggregate

//merge the names, nodes and acc2tax files and add them to the channel for metaDMG
ch_meta_requirements = ch_names.concat(ch_nodes, ch_acc2taxid).collect()
ch_bam_for_metadmg = ch_bam.combine(ch_meta_requirements)

METADMG_CPP(ch_bam_for_metadmg)

ch_tsv = METADMG_CPP.out.tsv

//
// 4. Report summary
//

// use the aggregate-table as base, add RG

ch_tsv.map{it -> [it[0], it[1].splitCsv(sep: '\t', header:true)]}
    .transpose()
    .map{it -> it[0]+it[1]}
    .collect()
    .map{it -> 
        def header = it[0].keySet().join('\t')
        def lines = it.collect { row -> row.values().join('\t') }
        ([header] + lines).join('\n')
    }
    .collectFile(name:'final_report.tsv', storeDir:'.' )
}

ch_versions.unique().collectFile(name: 'pipeline_versions.yml', storeDir:".")
