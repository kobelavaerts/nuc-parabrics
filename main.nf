#!/usr/bin/env nextflow

// include modules
include { pb_deepvariant_germline } from './modules/local/parabricks_deepvariant_germline/main.nf'



workflow {
    samplesheet_ch = channel.fromPath(params.samplesheet)
        .splitCsv(header: true, quote: '\"')
    
    samplesheet_ch | view

    input = samplesheet_ch
        .map {
            row -> 
            def meta = [:]
            meta.sample = row.sample
            meta.hapchr = row.hapchr
            meta.platform = row.platform
            meta.read_group = row.read_group
            tuple(meta, file(row.fq1), file(row.fq2), file(row.refidx), file(row.knownsites))
        }
    
    input | view

    pb_deepvariant_germline(input)

    pb_deepvariant_germline.out[0].view()
    pb_deepvariant_germline.out.bam.view()

}