#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

import groovy.json.JsonBuilder

include { start_ping; end_ping } from './lib/ping'


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
        path "versions/*"
        path "params.json"
    output:
        file "wf-demultiplex-*.html"
    script:
        report_name = "wf-demultiplex-" + params.report_name + '.html'

    """
    report.py $report_name barcoding_summary.txt --versions versions --params params.json

    """
}

process getVersions {
    label "barcoder"
    cpus 1
    output:
        path "versions.txt"
    script:
    """
    python --version | sed 's/^/python,/' >> versions.txt
    """
}


process getParams {
    label "barcoder"
    cpus 1
    output:
        path "params.json"
    script:
        def paramsJSON = new JsonBuilder(params).toPrettyString()
    """
    # Output nextflow params object to JSON
    echo '$paramsJSON' > params.json
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
        software_versions = getVersions()
        workflow_params = getParams()
        report = makeReport(data.summary, software_versions.collect(), workflow_params)
    emit:
        results = report.concat(data.barcodes, data.unclassified, data.summary)
        telemetry = workflow_params
}

// entrypoint workflow
WorkflowMain.initialise(workflow, params, log)
workflow {
    start_ping()
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
        pipeline(reads)
        output(pipeline.out.results)
    } else {
        println("No .fastq(.gz) files found under `${params.fastq}`.")
    }
    end_ping(pipeline.out.telemetry)
}
