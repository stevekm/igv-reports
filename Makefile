SHELL:=/bin/bash
UNAME:=$(shell uname)
export PATH:=$(CURDIR)/conda/bin:$(PATH)
unexport PYTHONPATH
unexport PYTHONHOME

# install versions of conda for Mac or Linux, Python 2 or 3
ifeq ($(UNAME), Darwin)
CONDASH:=Miniconda3-4.7.12.1-MacOSX-x86_64.sh
endif

ifeq ($(UNAME), Linux)
CONDASH:=Miniconda3-4.7.12.1-Linux-x86_64.sh
endif

CONDAURL:=https://repo.continuum.io/miniconda/$(CONDASH)
conda:
	@echo ">>> Setting up conda..."
	@wget "$(CONDAURL)" && \
	bash "$(CONDASH)" -b -p conda && \
	rm -f "$(CONDASH)"

install: conda
	conda config --add channels r
	conda config --add channels bioconda
	conda install -y pysam
	pip install igv-reports


# get other genome files;
# https://medium.com/@anton.babenko/aws-console-browse-public-s3-bucket-without-asking-for-listing-permission-bf84e62b45cb
# https://s3.console.aws.amazon.com/s3/object/igv.broadinstitute.org?region=us-east-1&prefix=genomes/seq/hg19/hg19.fasta
#  https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg38/hg38.fa
GENOME:=https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg38/hg38.fa
test-vcf:
	create_report \
	examples/variants/variants.vcf.gz \
	$(GENOME) \
	--ideogram examples/variants/cytoBandIdeo.txt \
	--flanking 1000 \
	--info-columns GENE TISSUE TUMOR COSMIC_ID GENE SOMATIC \
	--tracks examples/variants/variants.vcf.gz examples/variants/recalibrated.bam \
	examples/variants/refGene.sort.bed.gz \
	--output igvjs_viewer.html

# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/cytoBand.txt
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19_alias.tab
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.chrom.sizes
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.fai
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.gz
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.gz.fai
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.gz.gzi
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.genome


bash:
	bash
