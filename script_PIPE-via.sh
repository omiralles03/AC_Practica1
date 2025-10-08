#!/bin/bash

UPGRADE="PIPE-via"

# Obtener el directorio del script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ruta al simulador
SIMULATOR="$BASE_DIR/simplesim-3.0_ecx/sim-outorder"

# Parámetros comunes
FASTFWD=100000000
MAX_INST=100000000

# Parámetros de ejecución del procesador (basados en Intel Core i5-14400)
INT_FETCH_IFQSIZE=10
INT_DECODE_WIDTH=10
INT_ISSUE_WIDTH=10
INT_COMMIT_WIDTH=12
INT_RUU_SIZE=512 #576
INT_LSQ_SIZE=256 #309

# Configuración de latencias para cachés
INT_IL2LAT=23
INT_DL2LAT=23
INT_IL1LAT=11
INT_DL1LAT=4

# Configuración de cachés L1 y L2
INT_IL1_ASOC=8
INT_DL1_ASOC=8 #12
INT_DL2_ASOC=8 #10

INT_IL1_SIZE=64  # KB
INT_IL1_BSIZE=64 # Bytes

INT_DL1_SIZE=48  # KB
INT_DL1_BSIZE=64 # Bytes

INT_UL2_SIZE=3072 # KB
INT_UL2_BSIZE=64  # Bytes

INT_FIRST_CHUNK=125
INT_INTER_CHUNK=1
INT_MEM_WIDTH=16

INT_ALUI=6
INT_ALUF=8
INT_MULTI=3
INT_MULTF=2

# Parámetros de ejecución del procesador (basados en AMD Ryzen 5 7600X)
AMD_FETCH_IFQSIZE=10
AMD_DECODE_WIDTH=10
AMD_ISSUE_WIDTH=10
AMD_COMMIT_WIDTH=12
AMD_RUU_SIZE=512 #448
AMD_LSQ_SIZE=256 #306

# Configuración de latencias para cachés
AMD_IL2LAT=14
AMD_DL2LAT=14
AMD_IL1LAT=4
AMD_DL1LAT=4

# Configuración de cachés L1 y L2
AMD_IL1_ASOC=8
AMD_DL1_ASOC=8 #12
AMD_DL2_ASOC=16

AMD_IL1_SIZE=32  # KB
AMD_IL1_BSIZE=64 # Bytes

AMD_DL1_SIZE=48  # KB
AMD_DL1_BSIZE=64 # Bytes

AMD_UL2_SIZE=1024 # KB
AMD_UL2_BSIZE=64  # Bytes

AMD_FIRST_CHUNK=124
AMD_INTER_CHUNK=1
AMD_MEM_WIDTH=16

AMD_ALUI=6
AMD_ALUF=4
AMD_MULTI=3
AMD_MULTF=2

# Función para calcular el número más cercano que sea potencia de 2
nearsest_power2() {
    local n=$1
    local power=1
    while (( power < n )); do
        power=$(( power * 2 ))
    done
    echo $power
}

# Cálculo del número de conjuntos (sets) para cada caché y ajustar a potencia de 2
INT_IL1_SETS=$(nearsest_power2 $(( ($INT_IL1_SIZE * 1024) / ($INT_IL1_BSIZE * $INT_IL1_ASOC) )))
INT_DL1_SETS=$(nearsest_power2 $(( ($INT_DL1_SIZE * 1024) / ($INT_DL1_BSIZE * $INT_DL1_ASOC) )))
INT_UL2_SETS=$(nearsest_power2 $(( ($INT_UL2_SIZE * 1024) / ($INT_UL2_BSIZE * $INT_DL2_ASOC) )))

AMD_IL1_SETS=$(nearsest_power2 $(( ($AMD_IL1_SIZE * 1024) / ($AMD_IL1_BSIZE * $AMD_IL1_ASOC) )))
AMD_DL1_SETS=$(nearsest_power2 $(( ($AMD_DL1_SIZE * 1024) / ($AMD_DL1_BSIZE * $AMD_DL1_ASOC) )))
AMD_UL2_SETS=$(nearsest_power2 $(( ($AMD_UL2_SIZE * 1024) / ($AMD_UL2_BSIZE * $AMD_DL2_ASOC) )))

# Obtener el tiempo de inicio
start_time=$(date +%s)

# Benchmarks y sus comandos específicos
declare -A BENCHMARKS
BENCHMARKS["applu"]="< applu.in > applu.out 2> applu.err"
BENCHMARKS["art"]="-scanfile c756hel.in -trainfile1 a10.img -trainfile2 hc.img -stride 2 -startx 110 -starty 200 -endx 160 -endy 240 -objects 10 > ref.1.out 2> ref.1.err
-scanfile c756hel.in -trainfile1 a10.img -trainfile2 hc.img -stride 2 -startx 470 -starty 140 -endx 520 -endy 180 -objects 10 > ref.2.out 2> ref.2.err"
BENCHMARKS["gzip"]="input.source 60 > input.source.out 2> input.source.err
input.log 60 > input.log.out 2> input.log.err
input.graphic 60 > input.graphic.out 2> input.graphic.err
input.graphic 60 > input.graphic.out 2> input.graphic.err
input.random 60 > input.random.out 2> input.random.err
input.program 60 > input.program.out 2> input.program.err"
BENCHMARKS["mesa"]="-frames 1000 -meshfile mesa.in -ppmfile mesa.ppm"
BENCHMARKS["twolf"]="ref > ref.stdout 2> ref.err"

# Función para ejecutar una simulación
execute_simulation() {
    local BENCH=$1
    local EXE="$BASE_DIR/Benchmarks/$BENCH/exe/$BENCH.exe"
    local COMMAND="${BENCHMARKS[$BENCH]}"

    # Cambiar al directorio de referencia del benchmark
    local BENCH_DIR="$BASE_DIR/Benchmarks/$BENCH/data/ref"
    cd "$BENCH_DIR" || { echo "Error: No se pudo acceder al directorio $BENCH_DIR"; return; }

    # Directorio de salida para Intel
    local OUTPUT_DIR="$BASE_DIR/Upgrades/$UPGRADE/ResultsINT_${BENCH}.txt"
    # Construir la línea de comandos para sim-outorder (Intel)
    local SIM_COMMAND="$SIMULATOR -fastfwd $FASTFWD -max:inst $MAX_INST \
-fetch:ifqsize $INT_FETCH_IFQSIZE -decode:width $INT_DECODE_WIDTH -issue:width $INT_ISSUE_WIDTH -commit:width $INT_COMMIT_WIDTH \
-ruu:size $INT_RUU_SIZE -lsq:size $INT_LSQ_SIZE \
-cache:il1 il1:${INT_IL1_SETS}:${INT_IL1_BSIZE}:${INT_IL1_ASOC}:l -cache:il1lat $INT_IL1LAT \
-cache:dl1 dl1:${INT_DL1_SETS}:${INT_DL1_BSIZE}:${INT_DL1_ASOC}:l -cache:dl1lat $INT_DL1LAT \
-cache:dl2 ul2:${INT_UL2_SETS}:${INT_UL2_BSIZE}:${INT_DL2_ASOC}:l -cache:dl2lat $INT_DL2LAT \
-mem:lat $INT_FIRST_CHUNK $INT_INTER_CHUNK -mem:width $INT_MEM_WIDTH \
-res:ialu $INT_ALUI -res:fpalu $INT_ALUF \
-res:imult $INT_MULTI -res:fpmult $INT_MULTF \
-redir:sim $OUTPUT_DIR $EXE $COMMAND"

    echo "Executing simulation for $BENCH (INTEL):"
    echo "$SIM_COMMAND"
    eval $SIM_COMMAND

    # Directorio de salida para AMD
    local OUTPUT_DIR="$BASE_DIR/Upgrades/$UPGRADE/ResultsAMD_${BENCH}.txt"
    # Construir la línea de comandos para sim-outorder (AMD)
    local SIM_COMMAND="$SIMULATOR -fastfwd $FASTFWD -max:inst $MAX_INST \
-fetch:ifqsize $AMD_FETCH_IFQSIZE -decode:width $AMD_DECODE_WIDTH -issue:width $AMD_ISSUE_WIDTH -commit:width $AMD_COMMIT_WIDTH \
-ruu:size $AMD_RUU_SIZE -lsq:size $AMD_LSQ_SIZE \
-cache:il1 il1:${AMD_IL1_SETS}:${AMD_IL1_BSIZE}:${AMD_IL1_ASOC}:l -cache:il1lat $AMD_IL1LAT \
-cache:dl1 dl1:${AMD_DL1_SETS}:${AMD_DL1_BSIZE}:${AMD_DL1_ASOC}:l -cache:dl1lat $AMD_DL1LAT \
-cache:dl2 ul2:${AMD_UL2_SETS}:${AMD_UL2_BSIZE}:${AMD_DL2_ASOC}:l -cache:dl2lat $AMD_DL2LAT \
-mem:lat $AMD_FIRST_CHUNK $AMD_INTER_CHUNK -mem:width $AMD_MEM_WIDTH \
-res:ialu $AMD_ALUI -res:fpalu $AMD_ALUF \
-res:imult $AMD_MULTI -res:fpmult $AMD_MULTF \
-redir:sim $OUTPUT_DIR $EXE $COMMAND"
    
    echo "Executing simulation for $BENCH (AMD):"
    echo "$SIM_COMMAND"
    eval $SIM_COMMAND

    # Volver al directorio base después de la ejecución
    cd "$BASE_DIR" || { echo "Error: No se pudo regresar al directorio base $BASE_DIR"; exit 1; }
}

# Ejecutar simulaciones para todos los benchmarks
for BENCH in "${!BENCHMARKS[@]}"; do
    execute_simulation "$BENCH"
done

# Obtener el tiempo de finalización
end_time=$(date +%s)

# Calcular la diferencia de tiempo
execution_time=$((end_time - start_time))

# Convertir el tiempo a minutos y segundos
minutes=$((execution_time / 60))
seconds=$((execution_time % 60))

# Imprimir el tiempo de ejecución en formato min:seg
echo "Tiempo total de ejecución: $minutes min $seconds seg"
