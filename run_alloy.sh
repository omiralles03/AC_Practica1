#!/bin/bash

# Definim on és el simulador
SIM="./simplesim-3.0_ecx/sim-outorder"

# Creem carpeta per guardar els resultats nous
mkdir -p Results/Alloyed

# Definim les 6 configuracions de l'Alloyed (midaPaBHT midaPHT p g 0)
declare -a configs=(
    "8 8 1 1 0"         # Config 1
    "16 32 2 2 0"       # Config 2
    "32 128 2 3 0"      # Config 3
    "64 512 3 3 0"      # Config 4
    "128 2048 4 4 0"    # Config 5
    "64 4096 4 4 0"     # Config 6
)

# Execució de les simulacions.

count=1
for conf in "${configs[@]}"; do
    echo "========================================="
    echo "EXECUTANT CONFIGURACIÓ $count: $conf"
    echo "========================================="

    # --- BENCHMARK 1: GZIP ---
    echo "-> Gzip..."
    $SIM -fastfwd 100000000 -max:inst 100000000 \
         -bpred alloy -bpred:alloy $conf \
         -redir:sim Results/Alloyed/gzip_alloy_c${count}.txt \
         Benchmarks/gzip/exe/gzip.exe Benchmarks/gzip/data/ref/input.source 60

    # --- BENCHMARK 2: APPLU ---
    echo "-> Applu..."
    $SIM -fastfwd 100000000 -max:inst 100000000 \
         -bpred alloy -bpred:alloy $conf \
         -redir:sim Results/Alloyed/applu_alloy_c${count}.txt \
         Benchmarks/applu/exe/applu.exe < Benchmarks/applu/data/ref/applu.in

    # --- BENCHMARK 3: ART ---
    echo "-> Art..."
    $SIM -fastfwd 100000000 -max:inst 100000000 \
         -bpred alloy -bpred:alloy $conf \
         -redir:sim Results/Alloyed/art_alloy_c${count}.txt \
         Benchmarks/art/exe/art.exe \
         -scanfile Benchmarks/art/data/ref/c756hel.in \
         -trainfile1 Benchmarks/art/data/ref/a10.img \
         -trainfile2 Benchmarks/art/data/ref/hc.img \
         -stride 2 -startx 110 -starty 200 -endx 160 -endy 240 -objects 10

    # --- BENCHMARK 4: MESA ---
    echo "-> Mesa..."
    $SIM -fastfwd 100000000 -max:inst 100000000 \
         -bpred alloy -bpred:alloy $conf \
         -redir:sim Results/Alloyed/mesa_alloy_c${count}.txt \
         Benchmarks/mesa/exe/mesa.exe \
         -frames 1000 \
         -meshfile Benchmarks/mesa/data/ref/mesa.in \
         -ppmfile Benchmarks/mesa/data/ref/mesa.ppm

    # --- BENCHMARK 5: TWOLF ---
    echo "-> Twolf..."
    CURRENT_DIR=$(pwd)
    cd Benchmarks/twolf/data/ref/
    ../../../../$SIM -fastfwd 100000000 -max:inst 100000000 \
         -bpred alloy -bpred:alloy $conf \
         -redir:sim $CURRENT_DIR/Results/Alloyed/twolf_alloy_c${count}.txt \
         ../../exe/twolf.exe ref
    cd $CURRENT_DIR

    ((count++))
done

# Mostar els resultats

echo ""
echo "====================================================================="
echo "                        RESUM DE RESULTATS                           "
echo "====================================================================="
printf "%-10s %-10s %-15s %-15s\n" "BENCHMARK" "CONFIG" "IPC" "ENCERT (%)"
echo "---------------------------------------------------------------------"

# Llista de benchmarks
benchs=("gzip" "applu" "art" "mesa" "twolf")

# Recorrem per config i per benchmark
for ((c=1; c<=6; c++)); do
    for bench in "${benchs[@]}"; do
        file="Results/Alloyed/${bench}_alloy_c${c}.txt"
        
        if [ -f "$file" ]; then
            # Extraiem IPC
            ipc=$(grep "sim_IPC" "$file" | awk '{print $2}')
            
            # Extraiem Rate (i el convertim a percentatge multiplicant visualment)
            rate=$(grep "bpred_alloyed.bpred_dir_rate" "$file" | awk '{print $2}')
            
            # Si rate existeix, el mostrem, si no posem ERROR
            if [ -z "$rate" ]; then rate="ERROR"; fi
            if [ -z "$ipc" ]; then ipc="ERROR"; fi

            printf "%-10s %-10s %-15s %-15s\n" "$bench" "C$c" "$ipc" "$rate"
        else
            printf "%-10s %-10s %-15s %-15s\n" "$bench" "C$c" "NO TROBAT" "-"
        fi
    done
    echo "---------------------------------------------------------------------"
done

echo "Totes les simulacions han acabat!"
