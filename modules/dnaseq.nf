#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process checkUniqueIds {
  container = 'dnaseq'

  input:
    path params.fastaDir

  output:
    path 'check.txt'

  script:
    template 'checkUniqueIds.bash'
}


process makeIndex {
  container = 'veupathdb/dnaseqanalysis'

  publishDir "$params.outputDir", mode: "copy", pattern: 'combinedFasta.fa.fai'
  publishDir "$params.outputDir", mode: "copy", pattern: 'combinedFasta.fa'

  input:
    path ('combinedFasta.fa')
    path 'check.txt'

  output:
    path('combinedFasta.fa.fai')
    path('combinedFasta.fa') 

  script:
    template 'makeIndex.bash'
}


process mergeVcfs {
  container = 'biocontainers/bcftools:v1.9-1-deb_cv1'

  publishDir "$params.outputDir", mode: "copy", pattern: 'merged.vcf.gz'

  input:
    path '*.vcf.gz'
    path '*.vcf.gz.tbi'

  output:
    path 'merged.vcf.gz'
    path 'toSnpEff.vcf'

  script:
    template 'mergeVcfs.bash'
}


process snpEff {
  container = "dnaseq"

  publishDir "$params.outputDir", mode: "copy"

  input:
    path 'merged.vcf'
    path 'genes.gtf.gz'
    path 'sequences.fa.gz'

  output:
    path 'merged.ann.vcf'

  script:
    template 'snpEff.bash'    
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
    mergeVcfsResults = mergeVcfs(allvcfs, allvcfindexes)
    snpEff(mergeVcfsResults[1], params.databaseFile, params.sequenceFile)
}
