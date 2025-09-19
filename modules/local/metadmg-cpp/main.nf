process METADMG_CPP {
    container (workflow.containerEngine ? "merszym/metadmg:v0.4" : null)
    tag "$meta.id"

    input:
    tuple val(meta), path(bam), path(names), path(nodes), path(acc2tax)

    output:
    tuple val(meta), path("summarytable.tsv"), emit: tsv
    path "versions.yml"                      , emit: versions
    path "*.gz"                              , emit: gz

    script:
    """
    metaDMG-cpp lca --names ${names} --nodes ${nodes} --acc2tax ${acc2tax} \\
    --sim_score_low 0.95 --sim_score_high 1 --bam ${bam} --fix_ncbi 0 --out_prefix ${meta.id}.LCA &&

    metaDMG-cpp dfit ${meta.id}.LCA.bdamage.gz --names ${names} --nodes ${nodes} \\
    --showfits 2 --nopt 10 --nbootstrap 20 --doboot 1 --seed 1234 --lib ss --out_prefix ${meta.id}.DFIT &&

    metaDMG-cpp aggregate ${meta.id}.LCA.bdamage.gz --dfit ${meta.id}.DFIT.dfit.gz --out_prefix ${meta.id}.AGG --lcastat ${meta.id}.LCA.stat.gz \\
    --names ${names} --nodes ${nodes} &&
    
    zcat ${meta.id}.AGG.stat.gz > summarytable.tsv
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaDMG-cpp: \$(metaDMG-cpp version | head -1 | cut -d' ' -f3)
    END_VERSIONS
    """
}