process BOWTIE2 {
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bowtie2:2.5.4--he96a11b_5' :
        'quay.io/biocontainers/bowtie2:2.5.4--he96a11b_5' }"
    tag "$meta.id"

    input:
    tuple val(meta), path(fastq), val(index_name), path(bowtie_index)

    output:
    tuple val(meta), path("${meta.id}_classified.sam"), emit: sam
    path "versions.yml"                               , emit: versions

    script:
    """
    bowtie2 -x ${index_name} -U ${fastq} --no-unal -k 1000 -S ${meta.id}_classified.sam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(bowtie2 version | head -1 | cut -d' ' -f3)
    END_VERSIONS
    """
}