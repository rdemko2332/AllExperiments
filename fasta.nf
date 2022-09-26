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

//---------------------------------------------------------------
// Includes
//---------------------------------------------------------------

include { fasta } from './modules/fasta.nf'

//---------------------------------------------------------------
// Main Workflow
//---------------------------------------------------------------

workflow {

  fasta(fastas_qch)

}