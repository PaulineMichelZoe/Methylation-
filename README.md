# Methylation-
This document aims to simplify the future processing of bisulfite data in various methylation studies. The main steps in this pipeline are 1) Trim (primer extraction) 2) Maps (mapping of reads to the species reference sequence) 3) Annotation 4) Quantify (quantification of methylation levels at different genome scales). 

====================================================================================

    Purpose
    Dependencies
    Input data
    Example input data
    Quick start
    Example plot
    Detailed steps

Purpose:
sets of scripts to :

1 - perform de-novo TE detection,

2 - genome annotation using braker2

3 - identify synteny blocks and rearragnements (GeneSpace and Minimap)

4 - plot Ds along the genome using ancestral genomes

5 - perform changepoint analyses

Dependencies:

basic requirements: git, gcc , R, make, cmake, wget or curl , java

conda or mamba can be used to install several dependencies, especially without root access
First thing is to get mamba or conda.

I recommand mamba for linux:

curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge-pypy3-Linux-x86_64.sh
bash Miniforge-pypy3-Linux-x86_64.sh
#note: see here for other verions of mamba: https://github.com/conda-forge/miniforge

minimal dependencies:

see here to have a list of all dependencies or run directly :

git clone https://github.com/QuentinRougemont/genome_annotation
cd genome annotation
./requirements.sh #will work with mamba. alternatively replace by conda (sed -i 's/mamba/conda/g' requirements.sh) 

HOW TO USE:

After cloning the pipeline, please, work from within it to preserve the architecture

We recommend that you clone the pipeline for each of your new project and work within it.

Keep all project separated otherwise it will be difficult to recover your results.

 
Input data:

    minimal input:

        2 genomes assemblies (fasta files)

        additional settings (RNAseq data, etc) can be declared in the config file

more details on the config file are here
note on input naming:

we recommend to use short name for each haplotype and avoid any special characters appart from underscore.

For instance:

species-1.fasta will not be valid in GeneSpace. Use Species1.fasta instead.

For the chromosome we recommand a standard naming including the Species name within it like so:

Species1_chr1 or Species1_contig1

kepp things as simple as possible

# Example input data:

Compulsory

* genome1: `example_data/genome1.fa.gz`
* genome2: `example_data/genome2.fa.gz`
* config file: `example_data/example.config`

Optional data

* ancestral genome: `ancestral_genome/Mlag129A1.fa.gz`
* ancestral gff: `ancestral_genome/Mlag129A1.gtf.gz`
* RNAseq data:  `example_data/rnaseq.fq.gz`

TE data (compulsory)

* custom database: `example_data/TE.fa.gz`

Proteins for annotation (optional)

* example_data/prot.fa 
  note: if no protein data are available we will use orthoDB11  (downloaded automatically)

Quick start:

before running the pipeline make sure to have ALL dependencies installed

make sure to have the correct input data
step1 - edit the config file and set the correct path

the config file is here: ./config/config
step2 - run the master script

once the config file is ready with your path and dataset correctly simply run

./master.sh 2>&1 |tee log

this script should handle automatically the different use cases

Use case will be infered from the config file automatically. These can be:

    annotation only
    annotation, synteny, arrangement and Ds inference
    synteny, arrangement and Ds inference (if your already have annotations for your genomes)

for more details run:

./master.sh --help or ./master -h

Example Results

    1 - Genome Annotations

insert results here

    2 - Genome Annotation quality assesment based on busco:

insert busco plot here

    3a - minimap based divergence along the mating type chromosomes :

Fig2.png

    3b - minimap based whole genome alignment :

Fig3.png
