process SGA_PREPROCESS {
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sga:0.10.15--h26b121b_10' :
        'quay.io/biocontainers/sga:0.10.15--h26b121b_10' }"
    tag "$meta.id"

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("${fastq.baseName}_uniq.fq"), emit: fastq
    path "versions.yml"                               , emit: versions

    script:
    """
    sga preprocess --dust-threshold=1 -m 30 ${fastq} -o ${fastq.baseName}_pp.fq
    sga index --algorithm=ropebwt ${fastq.baseName}_pp.fq
    sga filter --no-kmer-check ${fastq.baseName}_pp.fq -o ${fastq.baseName}_uniq.fq

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sga: \$(sga --version | head -1 | cut -d' ' -f6)
    END_VERSIONS
    """
}