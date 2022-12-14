#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//---------------------------------------------------------------
// Param Checking 
//---------------------------------------------------------------

if(params.fastaDir) {
  fastas_qch = Channel.fromPath(params.fastaDir + '*.fa')
}
else {
  throw new Exception("Missing parameter params.fastaDir")
}

if(params.vcfDir) {
  vcfs_qch = Channel.fromPath(params.vcfDir + '*.vcf.gz')
  vcfsindex_qch = Channel.fromPath(params.vcfDir + '*.vcf.gz.tbi')
}
else {
  throw new Exception("Missing parameter params.vcfDir")
}

//---------------------------------------------------------------
// Includes
//---------------------------------------------------------------

include { AllExperiments } from './modules/AllExperiments.nf'

//---------------------------------------------------------------
// Main Workflow
//---------------------------------------------------------------

workflow {

  AllExperiments(fastas_qch, vcfs_qch, vcfsindex_qch)

}