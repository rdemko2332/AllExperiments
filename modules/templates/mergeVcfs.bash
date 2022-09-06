#!/usr/bin/env bash

set -euo pipefail
bcftools merge \
      -o merged.vcf.gz \
      -O z *.vcf.gz
