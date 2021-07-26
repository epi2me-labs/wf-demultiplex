# Workflow template

This repository contains a [nextflow](https://www.nextflow.io/) workflow
for running standalone demultiplexing of Oxford Nanopore Sequencing data.
It is not ordinarily necessary to run this workflow as other EPI2ME Labs
integrate this workflow step.


## Quickstart

The workflow uses [nextflow](https://www.nextflow.io/) to manage compute and 
software resources, as such nextflow will need to be installed before attempting
to run the workflow.

The workflow can currently be run using either
[Docker](https://www.docker.com/products/docker-desktop) or
[conda](https://docs.conda.io/en/latest/miniconda.html) to provide isolation of
the required software. Both methods are automated out-of-the-box provided
either docker of conda is installed.

It is not required to clone or download the git repository in order to run the workflow.
For more information on running EPI2ME Labs workflows [visit out website](https://labs.epi2me.io/wfindex).

**Workflow options**

To obtain the workflow, having installed `nextflow`, users can run:

```
nextflow run epi2me-labs/wf-demultiplex --help
```

to see the options for the workflow.

**Workflow outputs**

The primary outputs of the workflow include:

* FASTQ files containing demultiplexed reads,
* an HTML report document detailing the primary findings of the workflow.


## Useful links

* [nextflow](https://www.nextflow.io/)
* [docker](https://www.docker.com/products/docker-desktop)
* [conda](https://docs.conda.io/en/latest/miniconda.html)
