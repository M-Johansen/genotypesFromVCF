## Function to create human-readable .csv file from VCF genotype data

## Two input files needed:
# 1) "filename".vcf - extracted from the indexed (tabix) VCF file: 
## tabix $INPUT_VCF $CHR > "filename".vcf (or extract multiple chromosomes to the same file)
# 2) "filename".GT.FORMAT - file containing genotype data for the chromosome(s) in chromosomes.txt
## vcftools --gzvcf $INPUT_VCF --chr $CHR --extract-FORMAR-info GT --out " filename".GT.FORMAT

# Works with up to 2 ALT alleles

### Function ###

## Parameters:
#
# vcfNAME: directory and name of input vcf file ("filename".vcf)
# gtName: directory and name of input GT file ("filename".GT.FORMAT)
# outfile_name: directory and name of outfile. 
# directory_name: set working directory

# Needs dplyr and tidyr

genotype <- function(vcfName, 
                     gtName, 
                     outfile_name, 
                     directory_name)
  
{
 # Load relevant packages:
  library(dplyr)
  library(tidyr)
  
  # set working directory:
  setwd(directory_name)
  
  # Read in the vcf file:
  vcf <- read.table(vcfName, sep="\t", header = F)
  
  # Select only relevant columns and add column names to vcf file:
  vcf <- vcf %>% select(1:5)
  colnames(vcf) <- c("CHROM", "POS", "ID", "REF", "ALT")
  
  # if ALT has two different alleles in it then split into columns ALT and ALT2
  vcf <- vcf %>% separate(ALT, c("ALT", "ALT2"))
  
  # Change NAs in ALT2 to "0"
  vcf[is.na(vcf)] <- 0
  
  # Read in the GT file:
  gt <- read.table(gtName, sep="\t", header=T)
  
  # Select only the individuals in the dataset, removing CHROM and POS columns
  gt <- gt %>% select(-CHROM, -POS)
  
  # Transform to characters:
  gt <- gt %>% mutate_all(as.character)
  
  # Attach individual genotypes to the vcf file:
  vcf <- bind_cols(vcf,gt)
  
  # Loop through to rename symbols to readable genotypes: 
  for (i in 1:nrow(vcf)) {
    for (k in seq_along(vcf)) {
      if (vcf[i,k] == "0/0") {
        vcf[i,k] <- paste(paste0(vcf$REF[i]), paste0(vcf$REF[i]), sep="/")
      }
      if (vcf[i,k] == "0/1") {
        vcf[i,k] <- paste(paste0(vcf$REF[i]), paste0(vcf$ALT[i]), sep="/")
      }  
      if (vcf[i,k] == "1/1") {
        vcf[i,k] <- paste(paste0(vcf$ALT[i]), paste0(vcf$ALT[i]), sep="/")
      }
      if (vcf[i,k] == "0/2") {
        vcf[i,k] <- paste(paste0(vcf$REF[i]), paste0(vcf$ALT2[i]), sep="/")
      }
      if (vcf[i,k] == "1/2") {
        vcf[i,k] <- paste(paste0(vcf$ALT[i]), paste0(vcf$ALT2[i]), sep="/")
      }
      if (vcf[i,k] == "2/2") {
        vcf[i,k] <- paste(paste0(vcf$ALT2[i]), paste0(vcf$ALT2[i]), sep="/")
      }
    }
  }
  
  # Change back the 0 in ALT2 to . 
  vcf[,6][vcf[,6]==0] <- "."
  
  # Write out csv file:  
  write.csv(write.csv(vcf, file=outfile_name, row.names = F))
  
  return("FIN!");
  
}

########

# to run the function on several files without having to re-enter them 
# create one csv file where: 
# column 1 = vcf file ( path to the vcf file name)
# column 2 = genotype file (path to the gt file name)
# column 3 = outfile (name of outile)

# e.g vcf	gt	outfile
# ./data/vcf/$filename.vcf	./data/GT/$filename.GT.FORMAT	$filename.csv

# Remember to use the full path name to each file. 

chrms <- read.csv("path/to/input/file/chromosomes.csv", header=T)

# We can then run the function in a for loop to loop over each contig file:

for (line in 1:nrow(chrms)) {
  genotype(vcfName = paste0(chrms$vcf[line]), # paste the name of the vcf file from the contig file
           gtName = paste0(chrms$gt[line]), # paste the name of the gt file
           outfile_name = paste0(chrms$outfile[line]), # paste the name of outfile you want
           directory_name = "/path/to/working/directory/")
}


