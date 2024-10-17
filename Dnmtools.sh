#!/bin/bash

# Chemins des outils
TRIMGALORE="/home/ricardo/Tools/TrimGalore-0.6.10/trim_galore"
DNMTOOLS="/home/ricardo/miniconda3/envs/dnmtools_env/bin/dnmtools"
SAMTOOLS="samtools"

# Chemin des fichiers fasta
PATH_GENOME="./utile/fa"

# Chemin des fichiers fastq
PATH_FASTQ="./utile/raw_seq/Novogene_batch1/X204SC20111755-Z01-F001/raw_data"
# Chemin de travail
PATH_WD='pipeline_methylation'


# Afficher le chemin des fichiers fastq
echo "Chemin des fichiers FASTQ : $PATH_FASTQ"

# Boucle sur chaque fichier fastq correspondant à *_1.fq.gz
for file in "$PATH_FASTQ"/*/*_1.fq.gz; do
    # Récupérer le nom de fichier sans le chemin
    filename=$(basename "$file")

    # Enlever l'extension .gz et .fq
    filename_no_ext="${filename%.gz}"
    filename_no_ext2="${filename_no_ext%.fq}"
    filename_id="${filename_no_ext2%_1}"
    filname_genome="${filename_id%%_*}"
if [[ "$filename_id" == *_F* ]]; then
    filename_short="${filename_id%%_F*}"
elif [[ "$filename_id" == *_B* ]]; then
    filename_short="${filename_id%%_B*}"
else
    filename_short="$filename_id"  # Pas de modification si aucun motif trouvé
fi

    # Afficher les informations de fichiers
    echo "Fichier actuel : $file"
    echo "Nom du fichier : $filename"
    echo "ID du fichier : $filename_id"
    echo "Short name : $filename_short"
    echo "genome : $filname_genome"

    # Copier les fichiers fastq dans le répertoire de travail
    ln -s "$PATH_FASTQ"/* "$PATH_WD/fastq/"

    
    # Définir les chemins des fichiers fastq 
    pair1="$PATH_WD/fastq/${filename_short}/${filename_id}_1.fq.gz"
    pair2="$PATH_WD/fastq/${filename_short}/${filename_id}_2.fq.gz"

     # Liste des espèces et leur génome associé
    declare -A species_genome=(
        ["MvS1250A1"]="MvCa-1250-A1-R1-20151026.fa"
        ["MsAS573A1"]="MvKn-1118-A1-R2-11032019.fa"
        ["MvS1510A1"]="MvSilpar-01510-A1-R1-21012019_quiver.fa"
        ["MvSl1064A1"]="MvSl-1064-A1-R4.fa"
        ["MvSl1064A2"]="MvSl-1064-A2-R4.fa"
        ["MvSpar1252A1"]="MvSp-1252-A1-R1-20151027.fa"
        ["MvSvMlag1253A1"]="MvSv-1253-A1-R1-20151026.fa"
        ["MvSta1400A1"]="MviSta-1400-A1-R1-11032019.fa"
        ["MvSgra1299A1"]="MvSilgra-01299-0D-R1-21012019_quiver.f"
        ["MvSa1248A1"]="MvSa-1248-D-A1-R0-20150904.fa"
        ["MvMlat1509A1"]="MvMoelat-01509-A1-R1-21012019_quiver.fa"
    )

    # Vérifier si filname_genome correspond à une espèce dans species_genome
    if [[ -n "${species_genome[$filname_genome]}" ]]; then
        genome_file="${species_genome[$filname_genome]}"
        
        echo "Species genome : $genome_file"
        echo "Species : $filname_genome"

        # Ici, tu peux ajouter le code qui traite les fichiers en fonction de l'espèce
    else
        echo "Aucune correspondance pour l'espèce : $filname_genome"
    fi


        # Suppression des amorces des reads avec TrimGalore
        "$TRIMGALORE" --paired -q 0 --length 0 "$pair1" "$pair2"

        # Récupération des fichiers de sortie de TrimGalore
        trimmed_pair1="${filename_id}_1_val_1.fq"
        trimmed_pair2="${filename_id}_2_val_2.fq"

        # Exécution de DNMTOOLS avec les fichiers de TrimGalore
        "$DNMTOOLS" abismal -i "${PATH_GENOME}/${genome_file}.fai" \
            -s "${PATH_WD}/metrics/${filename_id}_stats.txt" \
            -o "${PATH_WD}/abismal.bam/${filename_id}_abismal.bam" \
            "$trimmed_pair1" "$trimmed_pair2"

        echo "Species genome indx :${PATH_GENOME}/${genome_file}.fai" 

        # Chemin vers le fichier duplication_stats.txt
        metrics_file="/home/pauline/pipeline_methylation/metrics/${filename_id}_stats.txt"  # Assurez-vous que ce chemin est correct

                # Vérifier si le fichier existe
        if [[ -f "$metrics_file" ]]; then
            # Extraire la 7e ligne et prendre le deuxième mot (pourcentage)
            percentage=$(sed -n '7p' "$metrics_file" | awk '{print $2}')  # Supposant que le pourcentage est le deuxième mot de la ligne

            # Vérifier si le pourcentage est inférieur à 70
            if (( $(echo "$percentage < 70" | bc -l) )); then
                # Déplacer le fichier abismal.bam vers un autre sous-dossier
                mv "${PATH_WD}/abismal.bam/${filename_id}_abismal.bam" "${PATH_WD}/abismal_under_70/${filename_id}_abismal.bam"
                echo "Fichier déplacé : ${filename_id}_abismal.bam vers abismal_under_70/"
            else
                echo "Le pourcentage de duplication ($percentage%) est supérieur ou égal à 70."
            fi
        else
            echo "Le fichier $metrics_file n'existe pas."
        fi

        # Calcul du taux de conversion bisulfite
        "$DNMTOOLS" bsrate -c  "${PATH_GENOME}/${genome_file}" -o "${filename_id}.bsrate"  "${PATH_WD}/abismal.bam/${filename_id}_abismal.bam"

        # Reformatage du fichier BAM et tri avec samtools
        "$DNMTOOLS" format -f abismal -B "${PATH_WD}/abismal.bam/${filename_id}_abismal.bam" "${PATH_WD}/abismal.bam/${filename_id}_abismal_format.bam" 
        "$SAMTOOLS" sort -o "${PATH_WD}/sorted.bam/${filename_id}_sorted.bam" "${PATH_WD}/abismal.bam/${filename_id}_abismal_format.bam"

        # Vérification et suppression des duplicats
        "$DNMTOOLS" uniq -S "${PATH_WD}/duplication_stats.txt/${filename_id}_duplication_stats.txt" "${PATH_WD}/sorted.bam/${filename_id}_sorted.bam" "${PATH_WD}/uniq/${filename_id}_uniq.bam"

        # Calcul des niveaux de méthylation à chaque cytosine génomique
        "$DNMTOOLS" counts -c "${PATH_GENOME}/${genome_file}" -o "${PATH_WD}/counts/${filename_id}_counts.txt" "${PATH_WD}/uniq/${filename_id}_uniq.bam"

        # Test des informations sur la couverture, méthylation moyenne, etc.
        "$DNMTOOLS" levels -o "${PATH_WD}/metrics/${filename_id}_levels.txt" "${PATH_WD}/counts/${filename_id}_counts.txt"

        # Suppression des brins symétriques (-)
        "$DNMTOOLS" sym "${filename_id}_counts.txt"

    done
done

# Sortir du script à la fin
exit 0