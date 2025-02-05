
process pb_deepvariant_germline {

    publishDir "${params.outdir}/mappings/", pattern: "*{.bam,.txt,duplicate_metrics}", mode: 'copy'
    publishDir "${params.outdir}/variants_XYhap/", pattern: "*.vcf", mode: 'copy'

    input:
    tuple(val(meta), path(fq1), path(fq2), path(refidx), path(knownsites))

    output:
    stdout
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.vcf.gz"), emit: vcf
    tuple val(meta), path("*{.txt,duplicate_metrics}"), emit: metrics


    script:
    // def hap_chr_arg = params.hap_chr? "--haploid-contigs ${params.hap_chr}" : ""
    def hap_chr_arg = meta.hapchr? "--haploid-contigs ${meta.hapchr}" : ""
    def num_gpus = task.accelerator ? "--num-gpus $task.accelerator.request" : ''
    def pfx = meta.read_group? "${meta.read_group}" : "${meta.sample}"

    """
    pbrun deepvariant_germline \
    --gpusort \
    --gpuwrite \
    ${num_gpus} \
    --bwa-options '-M -K 10000000' \
    --optical-duplicate-pixel-distance ${params.optdist} \
    --read-group-sm ${pfx} \
    --read-group-lb lib_${pfx} \
    --read-group-pl ${meta.platform} \
    --read-group-id-prefix ${pfx} \
    --ref ${refidx} \
    --in-fq ${fq1} ${fq2} \
    --knownSites ${knownsites} \
    ${hap_chr_arg} \
    --out-bam ${meta.sample}_mrkdup.bam \
    --out-recal-file ${meta.sample}_recal.txt \
    --out-duplicate-metrics ${meta.sample}_duplicate_metrics \
    --out-variants ${meta.sample}_XYhap.g.vcf.gz \
    --gvcf

    """

    stub:
    def hap_chr_arg = meta.hapchr? "--haploid-contigs ${meta.hapchr}" : ""
    def num_gpus = task.accelerator ? "--num-gpus $task.accelerator.request" : ''
    def pfx = meta.read_group? "${meta.read_group}" : "${meta.sample}"

    """
    echo "pbrun deepvariant_germline --gpusort --gpuwrite ${hap_chr_arg} ${num_gpus}"
    cat << EOF
    pbrun deepvariant_germline \
    --gpusort \
    --gpuwrite \
    ${num_gpus} \
    --bwa-options '-M -K 10000000' \
    --optical-duplicate-pixel-distance ${params.optdist} \
    --read-group-sm ${pfx} \
    --read-group-lb lib_${pfx} \
    --read-group-pl ${meta.platform} \
    --read-group-id-prefix ${pfx} \
    --ref ${refidx} \
    --in-fq ${fq1} ${fq2} \
    --knownSites ${knownsites} \
    ${hap_chr_arg} \
    --out-bam ${meta.sample}_mrkdup.bam \
    --out-recal-file ${meta.sample}_recal.txt \
    --out-duplicate-metrics ${meta.sample}_duplicate_metrics \
    --out-variants ${meta.sample}_XYhap.g.vcf.gz \
    --gvcf
    EOF
    
    touch ${meta.sample}_mrkdup.bam
    touch ${meta.sample}_recal.txt
    touch ${meta.sample}_duplicate_metrics
    touch ${meta.sample}_XYhap.g.vcf.gz

    """
}