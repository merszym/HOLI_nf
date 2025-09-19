process METADMG_CPP {
    container (workflow.containerEngine ? "merszym/metadmg:v0.4" : null)
    tag "$meta.id"

    input:
    tuple val(meta), path(bam), path(names), path(nodes), path(acc2tax)

    output:
    tuple val(meta), path("summarytable.tsv"), emit: tsv
    path "versions.yml"                      , emit: versions

    script:
    """
    metaDMG-cpp lca --names ${names} --nodes ${nodes} --acc2tax ${acc2tax} \\
    --sim_score_low 0.95 --sim_score_high 1 --bam ${bam} --fix_ncbi 0 --out_prefix LCA &&

    metaDMG-cpp dfit LCA.bdamage.gz --names ${names} --nodes ${nodes} \\
    --showfits 2 --nopt 10 --nbootstrap 20 --doboot 1 --seed 1234 --lib ss --out_prefix DFIT &&

    metaDMG-cpp aggregate LCA.bdamage.gz --dfit DFIT.dfit.gz --out_prefix AGG --lcastat LCA.stat.gz \\
    --names ${names} --nodes ${nodes} &&
    
    zcat AGG.stat.gz > summarytable.tsv
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaDMG-cpp: \$(metaDMG-cpp version | head -1 | cut -d' ' -f3)
    END_VERSIONS
    """
}