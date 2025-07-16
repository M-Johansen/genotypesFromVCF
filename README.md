Simple R function to create human-readable .csv file from VCF genotype data

Two input files needed:
1) "filename".vcf - extracted from the indexed (tabix) VCF file: 
tabix $INPUT_VCF $CHR > "filename".vcf (or extract multiple chromosomes to the same file)

2) "filename".GT.FORMAT - file containing genotype data for the chromosome(s) in chromosomes.vcf
vcftools --gzvcf $INPUT_VCF --chr $CHR --extract-FORMAR-info GT --out " filename".GT.FORMAT

Worsk with two alternative alleles. 


To run the function on several files without having to re-enter them create one csv file where: 
Column 1 = vcf file ( path/to/the/vcf/file/name)
Column 2 = genotype file (path/to/the/gt/file/name)
Column 3 = outfile (path/to/and/name/of/outile)
