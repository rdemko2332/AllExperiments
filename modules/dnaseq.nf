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
    """
    mkdir genome
    mv genes.gtf.gz genome
    mv sequences.fa.gz genome
    cp /usr/bin/snpEff/snpEff.config .
    if [ $params.databaseFileType = gtf ]; then
      java -jar /usr/bin/snpEff/snpEff.jar build -gtf22 -noCheckCds -noCheckProtein -v genome
    elif [ $params.databaseFileType = gff ]; then
      java -jar /usr/bin/snpEff/snpEff.jar build -gff3 -noCheckCds -noCheckProtein -v genome
    else
      echo "Params.databaseFileType is not gtf or gff"
    fi
    java -Xmx4g -jar /usr/bin/snpEff/snpEff.jar genome merged.vcf > merged.ann.vcf    
    """ 
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
