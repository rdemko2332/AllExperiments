#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process checkUniqueIds {
  container = 'veupathdb/allexperiments'

  input:
    path params.fastaDir

  output:
    path 'check.txt'

  script:
    template 'checkUniqueIds.bash'
}


process makeIndex {
  container = 'veupathdb/dnaseqanalysis'
  publishDir "$params.outputDir", mode: "copy", saveAs: { filename -> "combinedIndexedConsensus.fa.fai" }

  input:
    path ('combinedFasta.fa')
    path 'check.txt'

  output:
    path('combinedFasta.fa.fai') 

  script:
    template 'makeIndex.bash'
}

process mergeVcfs {
  container = 'biocontainers/bcftools:v1.9-1-deb_cv1'
  publishDir "$params.outputDir", mode: "copy", saveAs: { filename -> "merged.vcf.gz" }
  input:
    path '*.vcf.gz'
    path '*.vcf.gz.tbi'
  output:
    path 'merged.vcf.gz'
  script:
    template 'mergeVcfs.bash'
}

workflow dnaseq {

  take:
    fastas_qch
    vcfs_qch
    vcfsindex_qch

  main:

    checkResults = checkUniqueIds(params.fastaDir)
    combinedFasta = fastas_qch.collectFile(name: 'CombinedFasta.fa')
    makeIndex(combinedFasta, checkResults)

    allvcfs = vcfs_qch.collect()
    allvcfindexes = vcfsindex_qch.collect()
    mergeVcfs(allvcfs, allvcfindexes)
}
