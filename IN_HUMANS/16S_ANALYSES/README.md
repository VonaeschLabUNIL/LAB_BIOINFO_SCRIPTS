**Analysis of 16S rRNA gene sequencing data.**
Upon reception of the data, the DADA2 pipeline can be follow for read trimming, quality filtering, abundance profiling and taxonomy assignment using the SILVA database.

MiSeq and HiSeq data can be processed with: DADA2_16S_pipeline_HiSeq_MiSeq.Rmd

NovaSeq 6000 data can be processed with: DADA2_16S_pipeline_NovaSeq.Rmd

Processing can be done on the HPC cluster using: dada2_template.R

Submitted with: submit_dada2_run.sh

***Parameters need to be adapted for each dataset***
