#!/usr/bin/env nextflow

nextflow.enable.dsl = 2


def helpMessage(){
    log.info """
Demultiplexing workflow'

Usage:
    nextflow run epi2melabs/wf-demultiplex [options]

Script Options:
    --fastq        DIR     Path to directory containing FASTQ files (required)
    --out_dir      DIR     Path for output (default: $params.out_dir)
"""
}


process demultiplexReads {
    // demultiplex .fastq in a directory

    label "barcoder"
    cpus params.threads
    input:
        file "input"
    output:
        path "output/barcode*", emit: barcodes
        path "output/unclassified", emit: unclassified
        path "output/barcoding_summary.txt", emit: summary
    shell:
    """
    guppy_barcoder -i $input -s output -t $task.cpus
    """
}


process makeReport {
    label "barcoder"
    input:
        file "barcoding_summary.txt"
    output:
        file "wf-demultiplex-report.html"
    """
    report.py wf-demultiplex-report.html barcoding_summary.txt
    """
}


// See https://github.com/nextflow-io/nextflow/issues/1636
// This is the only way to publish files from a workflow whilst
// decoupling the publish from the process steps.
process output {
    // publish inputs to output directory
    label "barcoder"
    publishDir "${params.out_dir}", mode: 'copy', pattern: "*"
    input:
        file fname
    output:
        file fname
    """
    echo "Writing output files"
    """
}


// workflow module
workflow pipeline {
    take:
        reads
    main:
        data = demultiplexReads(reads)
        report = makeReport(data.summary)
    emit:
        report.concat(data.barcodes, data.unclassified, data.summary)
}

// entrypoint workflow
workflow {

    if (params.help) {
        helpMessage()
        exit 1
    }

    if (!params.fastq) {
        helpMessage()
        println("")
        println("`--fastq` is required")
        exit 1
    }

    reads = file("$params.fastq/*.fastq*", type: 'file', maxdepth: 1)
    if (reads) {
        reads = Channel.fromPath(params.fastq, type: 'dir', checkIfExists: true)
        results = pipeline(reads)
        output(results)
    } else {
        println("No .fastq(.gz) files found under `${params.fastq}`.")
    }
}
