process SAMTOOLS_SORT{
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.15.1--h1170115_0' :
        'quay.io/biocontainers/samtools:1.15.1--h1170115_0' }"
    tag "$meta.id"
    label "local"

    input:
    tuple val(meta), path(sam)

    output:
    tuple val(meta), path("${meta.id}_sorted.bam") , emit: bam
    path "versions.yml"                            , emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    samtools sort -n ${sam} -o ${meta.id}_sorted.bam  

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(samtools version | head -1 | cut -d' ' -f2)
    END_VERSIONS
    """
}