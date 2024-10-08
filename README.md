# Methylation-
This document aims to simplify the future processing of bisulfite data in various methylation studies. 
====================================================================================

   * [Purpose](#purpose)
   * [Dependencies](#dependencies)
   * [Input data](#input-data)
   * [Example input data](#example-input-data)
   * [Quick start](#quick-start)
 


# Purpose:
##  sets of scripts to : 
 1 - Trim (primer extraction), 

 2 - Maps (mapping of reads to the species reference sequence) 

 3 - Annotation and compartmentalisation  

 4 - Quantify (quantification of methylation levels at different genome scales) 





# Dependencies: 

basic requirements: **DNMTools**, **gcc** , **R**, **make**, **cmake**, **wget** or **curl** , **java** 

conda or **mamba** can be used to install several dependencies, especially without root access 

### First thing is to get mamba or conda. 

I recommand mamba for linux: 

```
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge-pypy3-Linux-x86_64.sh
bash Miniforge-pypy3-Linux-x86_64.sh
#note: see here for other verions of mamba: https://github.com/conda-forge/miniforge
```


# HOW TO USE:   

 
# Input data: 


* minimal input by species:
	* Bisulfite data [generated by the Novogène laboratory from extrated DNA] (**fastq files**) 
    * genomes assemblies (**single fasta file**)
 
 <img src="https://raw.githubusercontent.com/PaulineMichelZoe/Methylation-/main/Biseq-novogene.jpg" width="490" height="490">


We used Dnmtools software to map these reads onto the reference genome. Here We are obliged to use a third file as an adapter because the reference genomes and the sequences processed by novogenes had different names for the same species. The first step is to remove the primers that have also been amplified with abismal:
```
On a pas le Trim (voir Ricardo)
    awk '{for(i=2;i<=NF;i++) if($i!~/NA/) print $1,$i}' Documents/data/ref2bseq.txt | sed 's/B[0-9]://g;s/_bis/-bis/g;s/.fa /.idx /1' | awk '{split($NF,r,"_"); print $1,r[1]}' | awk '!s[$2]++' | sort -k2,2 | join -1 2 -2 1 - <(locate val_1.fq.gz | sed 's/_bis/-bis/g' | awk -F "/" '!/Trash/ {split($NF,s,"_"); print s[1],$0}' | awk '{gsub(/-bis/,"_bis",$NF); print}' | sort -k1,1) | awk '{print "abismal -t 10 -i /home/pauline/Documents/data/"$2" -s /home/pauline/Documents/data/mapstat/"$1"-"NR".mapstat -o /home/pauline/Documents/data/new/"$1"-"NR".sam "$NF,$NF}' | sed 's/1_val_1/2_val_2/2' | grep -f <(for i in $(locate val_1.fq.gz | awk -F "/" '!/Trash/ && !s[$NF]++'); do ls -lrt $i; done | awk '/mars/ && $(NF-2)==16 {print $NF}' | sort -u ) - |
```
The second step is to map the different reads to the reference genome. If the result of the mapping shows a similarity of less than 15% to the reference genome, it is considered to be a problem of contamination or poor DNA extraction and the replicas will not be kept for future analysis. 
```  
  awk '{gsub(/_bis/,"-bis",$0);  for(i=2;i<=NF;i++) if($i!~/NA/) print $1,$i}' Documents/data/ref2bseq.txt | awk '{split($NF,r,"_"); print $1,r[1]}' | awk '!s[$2]++ {sub(/^B[12]:/,"",$2); print}' | sort -k2,2 | join -1 2 -2 1 - <(find /home/pauline/Documents/data/new_data/ -name "*sorted.Sam-out-sorted.Sam" | sed 's/-bis/_bis/1' | awk -F "/" '{split($NF,p,"-"); print p[1],$0}' | sed 's/_bis/-bis/1'  | sort -k1,1) | awk '{print "dnmtools counts -c Documents/data/seqref/"$2"  -o Documents/data/new_data/"$1"-"NR".meth  "$3}'  | bash 
``` 
 ``` 
 find /home/pauline/Documents/data/hypermeth/ -name "*merge.meth"  | awk -F "/" '!/sorted/{split($NF,f,"."); print "dnmtools sym -m -o  /home/pauline/Documents/data/hypermeth/"f[1]"-CpG-merge.meth "$0}'| bash)
 ```



# Quick start:

***before running the pipeline make sure to have ALL dependencies installed***

***make sure to have the correct input data***

### step1 - edit the config file and set the correct path 

the config file is here: `./config/config`





# list of operations and tools


| __Operation__                     |  __Tools__                         |  __data type__  | 
|:---------------------------------:|:------------------------------:|:-----------:| 
| __read trimming__                |  Trimgalore                   | SeqBisulfite         | 
| __read mapping__                 |  abismal                    | SeqBisulfite          | 
| __sorting read__                 |  samtools                      | SeqBisulfite        |
| __mapping quality assement__     |  samtools + R                  | SeqBisulfite       |




This code has been tested with linux. 

# Data localisation 

## Annotated bed for parsing

### Original files
```

    - @GEEServ03:/home/marine/data/all_53G_TEs.gff3                 #All predicted TEs in 53 assemblies

    - @geeserv02:/home/ricardo/Trabajo/IT_IR/MicVault_2206/[MR]*gff3        #All gene models in 51 assemblies 

    - @geeserv02:/home/ricardo/Trabajo/seXYevol/PM_methylation/coord4parsing_v2.txt #AUT/PAR/NRR/CEN annotation par contig in PM's genomes 

        AUT = autosome

        CEN = centromere

        NRR = non recombinant region of imputed MAT chromosomes/contigs

        PAR = pseudo autosomal region of imputed MAT chromosomes/contigs
```
 
## Species already down

### Remind PM's genomes steems
```

  |     __Steem assembly__      |      __Steeem mC__     |     __Species name__      |       __Strain  Host__   | 
  |:------------------------:|:---------------------------:|:---------------:|:---------------:| 
  |   __MvCa-1250-A1-R1__     |   MvS1250A1   |   M. violaceum s.l.     1250    |   Silene caroliniana | 
  |   __MviSta-1400-A1__      |   MvSta1400A1   |  M. violaceum s.l.    1400     |  Silene tatarinowii | 
  |   __MvKn-1118-A1-R2__     |   MsAS573A1   |   M. scabiosae      1118     |  Knautia arvensins   | 
  |   __MvSilpar-01510-A1__    |  MvS1510A1   |   M. violaceum s.l.    1510    |   Silene parryi   | 
  |   __MvSl-1064-A1-R4__     |   MvSl1064A1   |  M. lychnidis-dioicae   1064    |   Silene latifolia    | 
  |   __MvSl-1064-A2-R4__    |    MvSl1064A2   |  M. lychnidis-dioicae     1064    |   Silene latifolia  | 
  |  __MvSp-1252-A1-R1__    |    MvSpar1252A1    |   M. violaceum s.l.      1252    |   Silene paradoxa  | 
  |  __MvSv-1253-A1-R1__     |   MvSvMlag1253A1   |  M. lagerheimii     1253    |   Silene vulgaris   | 
 
```

# Annotation and compartmentalisation 

## How to filtre merge documents

### On the fly generating merged file for parsing
```
@geeserv02:~/Trabajo/seXYevol/PM_methylation$ cat merger.sh

grep -f <(awk -F "_" '!s[$1]++{print $1}' /home/ricardo/Trabajo/seXYevol/PM_methylation/coord4parsing_v2.txt) <(ls -1 /home/ricardo/Trabajo/IT_IR/MicVault_2206/*gff3) | paste -s -d " " | awk '{print "cat "$0}' | bash
```

## Long (enough) TE for parsing
### TEs are considered long enough to be exposed to the RIP process from 300 base pairs. 
```
@geeserv02:~/Trabajo/seXYevol/PM_methylation$ awk -F "_" '!s[$1]++{print $1}' coord4parsing_v2.txt | grep -f - ../../IT_IR/MicVault_2206/all_53G_TEs.gff3 | sed 's/_/\t/1' | cut -f2- | awk '$5-$4>298' | sort -k1,1 -k4,4n -o PMset_longMicroTEp.gff3
```

### Annotation and intersection summary
```
@geeserv02:~/Trabajo/seXYevol/PM_methylation$ awk '$3=="gene"{split($1,s,"_"); c[s[1]]++}END{for(i in c) print i,c[i]}' <(./merger.sh) | sed '1iAAspe gALL' | sort | join -j1 - <(awk '/NRR|PAR/ && !s[$1]++{print $1}' coord4parsing_v2.txt | grep -f - <(./merger.sh) | awk '$3=="gene"{split($1,s,"_"); c[s[1]]++}END{for(i in c) print i,c[i]}' | sed '1iAAspe gMAT' | sort) | join -j1 - <(awk -F "_" '{c[$1]++}END{for(i in c) print i,c[i]}' PMset_longMicroTEp.gff3 | sed '1iAAspe tALL' | sort) | join -j1 - <(awk '/NRR|PAR/ && !s[$1]++{print $1}' coord4parsing_v2.txt | grep -f - PMset_longMicroTEp.gff3 | awk -F "_" '{c[$1]++}END{for(i in c) print i,c[i]}' | sed '1iAAspe tMAT' | sort)  | join -j1 - <(bedtools intersect -a <(awk '$3=="gene"' <(./merger.sh)) -b PMset_longMicroTEp.gff3 -wo | awk '$NF>=100 && !s[$1$4$5]++{split($1,g,"_"); c[g[1]]++}END{for(i in c) print i,c[i]}' | sed '1iAAspe nALL' | sort) | join -j1 - <(bedtools intersect -a <(awk '$3=="gene"' <(./merger.sh)) -b PMset_longMicroTEp.gff3 -wo | grep -f <(awk '/NRR|PAR/ && !s[$1]++{print $1}' coord4parsing_v2.txt) - | awk '$NF>=100 && !s[$1$4$5]++{split($1,g,"_"); c[g[1]]++}END{for(i in c) print i,c[i]}' | sed '1iAAspe nMAT' | sort) > annotANDintersect_summary4PM
```

          [Mind that I am counting only intersections at least 100 bp long]

## Visualisation of compartiment (MAT vs ALL)
```
      $ column -t annotANDintersect_summary4PM

    AAspe              gALL   gMAT  tALL  tMAT  nALL  nMAT

    MvCa-1250-A1-R1    10695  990   2345  435   1648  324

    MvKn-1118-A1-R2    8007   388   789   51    566   40

    MvSilpar-01510-A1  10156  1018  1783  471   1298  335

    MvSl-1064-A1-R4    12266  1517  2653  655   2191  558

    MvSl-1064-A2-R4    12516  1830  2742  804   2231  659

    MvSp-1252-A1-R1    15486  4333  6492  2234  3948  1883

    MvSv-1253-A1-R1    9532   1202  1519  275   769   160

    MviSta-1400-A1     8920   582   1041  217   749   139

    ###Fisher's test render all nMAT/gMAT vs nALL/gALL comparisons significant 

    ###Fold enrichment range 1.46 to 2.84; p-value range 0.037 to 2.165148e-57
```

####Details of annotation
```{r pressure}

#Adding genes fully contained in TE (gINt) and TE fully contained in genes (tINg), monster call alert

@geeserv02:~/Trabajo/seXYevol/PM_methylation$ bedtools intersect -a <(awk '$3=="gene"' <(./merger.sh)) -b PMset_longMicroTEp.gff3 -wo | awk '$NF>=100 && $13>=$4 && $14<=$5 && !s[$1$4$5]++{split($1,g,"_"); c[g[1]]++}END{for(i in c) print i,c[i]}' | sort | join -j1 - <(bedtools intersect -a <(awk '$3=="gene"' <(./merger.sh)) -b PMset_longMicroTEp.gff3 -wo | grep -f <(awk '/NRR|PAR/ && !s[$1]++{print $1}' coord4parsing_v2.txt) - | awk '$NF>=100 && $13>=$4 && $14<=$5 && !s[$1$4$5]++{split($1,g,"_"); c[g[1]]++}END{for(i in c) print i,c[i]}' | sort) | join -j1 - <(bedtools intersect -a <(awk '$3=="gene"' <(./merger.sh)) -b PMset_longMicroTEp.gff3 -wo | awk '$NF>=100 && $13<$4 && $14>$5 && !s[$1$4$5]++{split($1,g,"_"); c[g[1]]++}END{for(i in c) print i,c[i]}' | sort | join -j1 - <(bedtools intersect -a <(awk '$3=="gene"' <(./merger.sh)) -b PMset_longMicroTEp.gff3 -wo | grep -f <(awk '/NRR|PAR/ && !s[$1]++{print $1}' coord4parsing_v2.txt) - | awk '$NF>=100 && $13<$4 && $14>$5 && !s[$1$4$5]++{split($1,g,"_"); c[g[1]]++}END{for(i in c) print i,c[i]}' | sort)) | sed '1iAAspe tINgALL tINgMAT gINtALL gINtMAT' | join -j1 annotANDintersect_summary4PM - | sort -o annotANDintersect_summary4PM

##Visualisation of compartiment ( MAT vs ALL)

      $ sed '1i1 2 3 4 5 6 7 8 9 10 11' annotANDintersect_summary4PM | column -t

    1                  2      3     4     5     6     7     8        9        10       11

    AAspe              gALL   gMAT  tALL  tMAT  nALL  nMAT  tINgALL  tINgMAT  gINtALL  gINtMAT

    MvCa-1250-A1-R1    10695  990   2345  435   1648  324   447      99       581      99

    MvKn-1118-A1-R2    8007   388   789   51    566   40    168      12       186      15

    MvSilpar-01510-A1  10156  1018  1783  471   1298  335   346      91       442      108

    MvSl-1064-A1-R4    12266  1517  2653  655   2191  558   551      147      767      196

    MvSl-1064-A2-R4    12516  1830  2742  804   2231  659   562      185      765      216

    MvSp-1252-A1-R1    15486  4333  6492  2234  3948  1883  966      385      1439     739

    MvSv-1253-A1-R1    9532   1202  1519  275   769   160   203      41       245      52

    MviSta-1400-A1     8920   582   1041  217   749   139   220      45       280      48

    ###More than half (58 to 68%) of the intersection correspond to gINt or tINg, not obvious entichment in MAT
    ###Most (70%) predicted TEs overlap a gene feature

    ```{r pressure, echo=FALSE}
    
$ awk '{c[$2]++}END{for(i in c) print i,c[i]}' <(cat <(awk '$3=="gene"' <(./merger.sh)) PMset_longMicroTEp.gff3)

        TEannotationMD 19364

        EuGene 87578

          $ bedtools intersect -a PMset_longMicroTEp.gff3 -b <(awk '$3=="gene"' <(./merger.sh)) -wo | awk '{if(!s[$1$4$5]++) t++; \

        if(!s[$1$13$14]++) g++}END{print t,g}' 

        13726 14174
```


        
###Feature annotation cases
```{r pressure, echo=FALSE}
    1. TE is fully contained in gene "tINg": sT > sG & eT < eG

    nnnnnGGGGGGGGGGGGGGGGGGGGnnnnn

    nnnnnEEEEEiiiiEEEEEEEEEEEnnnnn

    nnnnnnnnTTTTTTTTTnnnnnnnnnnnnn

        -> Keep gene and TE, check gene orthology and annotation

    

    2. Short TE-gene overlap "tSOg": (sT > sG & eT > eG) | (sT < sG & eT < eG); overlap < 100 bp

    nnnGGGGGGGGGGGGGGGGnnnnnnnnnnn

    nnnEEEEEEiiiEEEEEEEnnnnnnnnnnn

    nnnnnnnnnnnnnnTTTTTTTTTTTTnnnn

        -> Kepp gene and TE, check gene orthology and annotation

    

    3. Gene is fully contained in TE "gINt": sT < sG & eT > eG

    nnnnnnnnnGGGGGGGGGGGGGnnnnnnnn

    nnnnnnnnnEEEEEiiiEEEEEnnnnnnnn

    nnnnnTTTTTTTTTTTTTTTTTTTTnnnnn

        -> Keep TE, mind that gene is likely a retrotrasponson protein domain and so worth checking Pfam hits and, eventually, orthology

    

    4. Large TE-gene overlap "gLOt": (sT > sG & eT > eG) | (sT < sG & eT < eG); overlap >= 100 bp

    nnnGGGGGGGGGGGGGGGGnnnnnnnnnnn

    nnnEEEEEEiiiEEEEEEEnnnnnnnnnnn

    nnnnnTTTTTTTTTTTTTTTTTTTTTnnnn

        -> Keep TE, mind that gene might have been invaded by the TE and so maybe worth checking gene orthology

    

    5. No TE-gene overlap "gNOt" or "tNOg"

    nnnnnnnnnnnnGGGGGGGGGGGGGGGGnn

    nnnnnnnnnnnnEEEEEEiiiEEEEEEEnn

    nTTTTTTTTTTTnnnnnnnnnnnnnnnnnn  

        -> Keep both
```

#### Way to call diff features 
```{r pressure, echo=FALSE}
###Disjoint features file including either gNOt and tNOg features

@geeserv02:~/Trabajo/seXYevol/PM_methylation$ bedtools intersect -b PMset_longMicroTEp.gff3 -a <(awk '$3=="gene"' <(./merger.sh)) -v | cat  - <(bedtools intersect -a PMset_longMicroTEp.gff3 -b <(awk '$3=="gene"' <(./merger.sh)) -v) | awk '{if(/EuGene/) $10="gNOt"; else $10="tNOg"; print}' OFS="\t" | sort -k1,1 -k4,4n -o PMset_keepeither.gff3

###Keep both features file including tINg and tSOg

@geeserv02:~/Trabajo/seXYevol/PM_methylation$ bedtools intersect -b PMset_longMicroTEp.gff3 -a <(awk '$3=="gene"' <(./merger.sh)) -wo | awk '{if($NF<100) print $0"~tSOg"; else if($13>=$4 && $14<=$5 && $NF>=100) print $0"~tINg"}' | sed 's/\t/~/9;s/\t/~/17' | awk -F "~" '{if(!s[$1]++) print $1"\t"$NF; if(!s[$2]++) print $2"\t"$4}'| sort -k1,1 -k4,4n -o PMset_keepboth.gff3

###Keep TE features file including gINt and gLOt

@geeserv02:~/Trabajo/seXYevol/PM_methylation$ bedtools intersect -a <(awk '$3=="gene"' <(./merger.sh)) -b PMset_longMicroTEp.gff3 -wo | awk '$NF>=100 {if($13<$4 && $14>$5) print $0"~gINt"; else if($13<$4 || $14>$5) print $0"~gLOt"}' OFS="\t" | sed 's/\t/~/9;s/\t/~/17' | awk -F "~" '{if(!s[$1]++) print $1,$NF; if(!s[$2]++) print $2,$NF}' OFS="\t"| grep -v -f <(cut -f1-9 PMset_disjoint.gff3 PMset_keepboth.gff3) - | awk '/TEan/' | sort -k1,1 -k4,4n -o PMset_keepTE.gff3

    ###Notice that the same call can parse the 9513 genes removed due to gINt and gLOt overlaps
```

```{r pressure, echo=FALSE}
###Annotate bed file for parsing, shared with PM

@geeserv02:~/Trabajo/seXYevol/PM_methylation$ bedtools subtract -a PMset_length.bed -b <(sort -k1,1 -k4,4n PMset_keep*) | awk '{$4="intg"; print}' OFS="\t" | cat - <(awk '{print $1,$4-1,$5,$NF,$2}' PMset_keep*) | sort -k1,1 -k2,2n | sed 's/ /\t/g' | sed 's/EuGene/Gene/1;s/TEa.\+$/TE/1;/intg/ s/$/\tintergenic/1' > PMset_annot4parsing.bed

    ###Mind that I am substracting one position from the start-of-the-feature for features coming from gff3 files

###Exemple des différents annotations
@geeserv02:~$ awk '/MvSl-1064-A1-R4_A1/ && !s[$(NF-1)$NF]++' /home/ricardo/Trabajo/seXYevol/PM_methylation/PMset_annot4parsing.bed 
MvSl-1064-A1-R4_A1	0		453		gNOt	Gene
MvSl-1064-A1-R4_A1	453		1056	intg	intergenic
MvSl-1064-A1-R4_A1	2562	6967	tINg	Gene
MvSl-1064-A1-R4_A1	2641	3925	tINg	TE
MvSl-1064-A1-R4_A1	37388	37861	gINt	TE
MvSl-1064-A1-R4_A1	43392	44651	gLOt	TE
MvSl-1064-A1-R4_A1	214301	214607	tNOg	TE
MvSl-1064-A1-R4_A1	224545	224905	tSOg	Gene
MvSl-1064-A1-R4_A1	224866	225300	tSOg	TE

###Dénombrer les différents cas, exemple avec MvSl
@geeserv02:~$ awk '/MvSl/{split($1,a,"_"); c[a[1]" "$(NF-1)" "$NF]++}END{for(i in c) print i,c[i]}' /home/ricardo/Trabajo/seXYevol/PM_methylation/PMset_annot4parsing.bed | sort | column -t
MvSl-1064-A1-R4  gINt  TE          314
MvSl-1064-A1-R4  gLOt  TE          892
MvSl-1064-A1-R4  gNOt  Gene        9932
MvSl-1064-A1-R4  intg  intergenic  11660
MvSl-1064-A1-R4  tINg  Gene        521
MvSl-1064-A1-R4  tINg  TE          791
MvSl-1064-A1-R4  tNOg  TE          357
MvSl-1064-A1-R4  tSOg  Gene        256
MvSl-1064-A1-R4  tSOg  TE          299
MvSl-1064-A2-R4  gINt  TE          306
MvSl-1064-A2-R4  gLOt  TE          923
MvSl-1064-A2-R4  gNOt  Gene        10142
MvSl-1064-A2-R4  intg  intergenic  11964
MvSl-1064-A2-R4  tINg  Gene        532
MvSl-1064-A2-R4  tINg  TE          800
MvSl-1064-A2-R4  tNOg  TE          411
MvSl-1064-A2-R4  tSOg  Gene        261
MvSl-1064-A2-R4  tSOg  TE          302


```




