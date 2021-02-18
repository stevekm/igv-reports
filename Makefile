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
	# pip install igv-reports
	# pip install -e . --user #

install-pip:install
	pip install igv-reports

install-repo:install
	python setup.py install

install-dev: install
	pip install -r requirements.txt
	python setup.py install

# NOTE: pip kept installing verion 1.0.1 of igv-reports, which lacked some needed bug fixes, so install directly from the repo here
# pip install igv-reports
# pip install -e . --user #
# install-dev: install
# 	pip install -r requirements.txt

# get other genome files;
# https://medium.com/@anton.babenko/aws-console-browse-public-s3-bucket-without-asking-for-listing-permission-bf84e62b45cb
# https://s3.console.aws.amazon.com/s3/object/igv.broadinstitute.org?region=us-east-1&prefix=genomes/seq/hg19/hg19.fasta
#  https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg38/hg38.fa
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/cytoBand.txt
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19_alias.tab
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.chrom.sizes
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.fai
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.gz
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.gz.fai
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.gz.gzi
# https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.genome

GENOME_DIR:=genomes
HG19_DIR:=$(GENOME_DIR)/hg19
HG38_DIR:=$(GENOME_DIR)/hg38
$(GENOME_DIR):
	mkdir -p "$(GENOME_DIR)"
$(HG38_DIR):
	mkdir -p $(HG38_DIR)
$(HG19_DIR):
	mkdir -p $(HG19_DIR)
hg38: $(HG38_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg38/hg38.fa -O $(HG38_DIR)/hg38.fa


$(HG19_DIR)/hg19.fasta: $(HG19_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta -O $(HG19_DIR)/hg19.fasta
$(HG19_DIR)/cytoBand.txt: $(HG19_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/cytoBand.txt -O $(HG19_DIR)/cytoBand.txt
$(HG19_DIR)/hg19_alias.tab: $(HG19_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19_alias.tab -O $(HG19_DIR)/hg19_alias.tab
$(HG19_DIR)/hg19.chrom.sizes: $(HG19_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.chrom.sizes -O $(HG19_DIR)/hg19.chrom.sizes
$(HG19_DIR)/hg19.fasta.fai: $(HG19_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.fai -O $(HG19_DIR)/hg19.fasta.fai
$(HG19_DIR)/hg19.fasta.gz: $(HG19_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.gz -O $(HG19_DIR)/hg19.fasta.gz
$(HG19_DIR)/hg19.fasta.gz.fai: $(HG19_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.gz.fai -O $(HG19_DIR)/hg19.fasta.gz.fai
$(HG19_DIR)/hg19.fasta.gz.gzi: $(HG19_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta.gz.gzi -O $(HG19_DIR)/hg19.fasta.gz.gzi
$(HG19_DIR)/hg19.genome: $(HG19_DIR)
	wget https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.genome -O $(HG19_DIR)/hg19.genome

HG19_FILES:= $(HG19_DIR)/hg19.fasta $(HG19_DIR)/cytoBand.txt $(HG19_DIR)/hg19_alias.tab $(HG19_DIR)/hg19.chrom.sizes $(HG19_DIR)/hg19.fasta.fai $(HG19_DIR)/hg19.fasta.gz $(HG19_DIR)/hg19.fasta.gz.fai $(HG19_DIR)/hg19.fasta.gz.gzi $(HG19_DIR)/hg19.genome

hg19: $(HG19_FILES)


examples/variants/refGene.sort.no_chr.bed: examples/variants/refGene.sort.bed
	sed -e 's|^chr||g' examples/variants/refGene.sort.bed > examples/variants/refGene.sort.no_chr.bed

examples/variants/cytoBandIdeo.no_chr.txt: examples/variants/cytoBandIdeo.txt
	sed -e 's|^chr||g' examples/variants/cytoBandIdeo.txt > examples/variants/cytoBandIdeo.no_chr.txt

# GENOME:=https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg38/hg38.fa
# GENOME:=https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta
# GENOME:=https://s3.amazonaws.com/igv.broadinstitute.org/genomes/seq/hg19/hg19.fasta
GENOME:=$(HG19_DIR)/hg19.fasta
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


test-vcf2:
	create_report \
	examples/variants/variants.vcf.gz \
	$(GENOME) \
	--ideogram examples/variants/cytoBandIdeo.txt \
	--flanking 1000 \
	--info-columns AC \
	--tracks examples/variants/variants.vcf.gz examples/variants/recalibrated.bam \
	examples/variants/refGene.sort.bed.gz \
	--output igvjs_viewer.html


test:
	python -m unittest test.test_table
.PHONY:test


VCF=
BAM1=
BAM2=
OUTPUT=igvjs_viewer.html
report: examples/variants/refGene.sort.no_chr.bed
	create_report \
	"$(VCF)" \
	"$(GENOME)" \
	--ideogram examples/variants/cytoBandIdeo.no_chr.txt \
	--flanking 1000 \
	--info-columns MAPQ SVTYPE SPAN EVDNC \
	--sample-columns LO DP AD SR \
	--tracks \
	"$(VCF)" \
	"$(BAM1)" \
	"$(BAM2)" \
	examples/variants/refGene.sort.no_chr.bed.gz \
	--output "$(OUTPUT)"

BAM1:=
BAM2:=
report2: examples/variants/refGene.sort.no_chr.bed examples/variants/cytoBandIdeo.no_chr.txt
	create_report \
	"$(VCF)" \
	"$(GENOME)" \
	--ideogram examples/variants/cytoBandIdeo.no_chr.txt \
	--flanking 1000 \
	--info-columns MAPQ \
	--sample-columns LO DP AD GT \
	--tracks \
	"$(VCF)" \
	"$(BAM1)" "$(BAM2)" \
	examples/variants/refGene.sort.no_chr.bed \
	--output "$(OUTPUT)"
#  \
# --info-columns MAPQ SVTYPE \
# --sample-columns tumor.bam normal.bam
# INFO
# MAPQ
# SVTYPE

# FILTER
# PASS
#
# FORMAT
# LO DP AD

##SAMPLE=<ID=tumor.bam>
##SAMPLE=<ID=normal.bam>

# ValueError: could not create iterator for region '1:4918433-4919434'
# Yes this error occurs when you have a structural variant on a contig that's not present in the SNV VCF. I think I resolved the issue with this commit 155e2b5
# https://github.com/dantaki/SV2/issues/8
# NOTE: had to make sure the chrom labels matched between the VCF and the ref files


bash:
	bash
